#!/usr/bin/env bash
set -Eeuo pipefail

export LANG=C.UTF-8
WORK_DIR=/etc/xray
GITHUB_PROXY=("https://ess.ieshare.workers.dev/")

color() { printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
green() { color '1;32' "$1"; }
yellow() { color '1;33' "$1"; }
red() { color '1;91' "$1" >&2; }
die() { red "$1"; exit 1; }

usage() {
    cat <<'EOF'
Usage (existing parameter style):
  xray-go.sh reality"n" h3"y" argo protocol"quic" port"8001" domain"tunnel.example.com" token"<TOKEN>"

Use reality"n" or h3"n" to disable that listener. Argo requires a Cloudflare
Tunnel token and a Public Hostname routed to http://127.0.0.1:<port>.
EOF
}

# Download an asset from GitHub, with an optional configured mirror fallback.
download_file() {
    local output_path=$1 official_url=$2 proxy proxy_url
    local validate_file() {
        [ -s "$1" ] || return 1
        if [[ "$1" == *.zip ]]; then
            unzip -tq "$1" >/dev/null 2>&1
        else
            [ "$(stat -c%s "$1" 2>/dev/null || wc -c <"$1")" -gt 1000000 ]
        fi
    }
    echo "Downloading $(basename "$output_path")..."
    if curl -fLsS --connect-timeout 15 --max-time 180 --retry 2 -o "$output_path" "$official_url" && validate_file "$output_path"; then
        return 0
    fi
    rm -f "$output_path"
    for proxy in "${GITHUB_PROXY[@]}"; do
        proxy_url="${proxy}${official_url}"
        if curl -fLsS --connect-timeout 15 --max-time 180 --retry 1 -o "$output_path" "$proxy_url" && validate_file "$output_path"; then
            return 0
        fi
        rm -f "$output_path"
    done
    return 1
}

ARG_H3=""
ARG_REALITY=""
ARG_ARGO_PROTOCOL="quic"
ARG_ARGO_PORT="8001"
ARG_ARGO_DOMAIN=""
ARG_ARGO_TOKEN=""
for arg in "$@"; do
    clean_arg=${arg//\"/}
    clean_arg=${clean_arg//\'/}
    if [[ "$clean_arg" =~ ^[hH]3(.*)$ ]]; then
        ARG_H3=${BASH_REMATCH[1]}
    elif [[ "$clean_arg" =~ ^[rR][eE][aA][lL][iI][tT][yY](.*)$ ]]; then
        ARG_REALITY=${BASH_REMATCH[1]}
    elif [[ "$clean_arg" =~ ^([aA][rR][gG][o])?[pP][rR][oO][tT][oO][cC][oO][lL](.*)$ ]]; then
        ARG_ARGO_PROTOCOL=${BASH_REMATCH[2]}
    elif [[ "$clean_arg" =~ ^([aA][rR][gG][o])?[pP][oO][rR][tT](.*)$ ]]; then
        ARG_ARGO_PORT=${BASH_REMATCH[2]}
    elif [[ "$clean_arg" =~ ^([aA][rR][gG][o])?[dD][oO][mM][aA][iI][nN](.*)$ ]]; then
        ARG_ARGO_DOMAIN=${BASH_REMATCH[2]}
    elif [[ "$clean_arg" =~ ^([aA][rR][gG][o])?[tT][oO][kK][eE][nN](.*)$ ]]; then
        ARG_ARGO_TOKEN=${BASH_REMATCH[2]}
    elif [[ "$clean_arg" =~ ^[0-9]+$|^[yYnN]$ ]]; then
        if [ -z "$ARG_H3" ]; then ARG_H3=$clean_arg
        elif [ -z "$ARG_REALITY" ]; then ARG_REALITY=$clean_arg
        fi
    fi
done

parse_port() {
    case "$1" in
        [nN]) printf '';;
        [yY]) shuf -i 10000-60000 -n 1;;
        '') printf ''; ;;
        *[!0-9]*) printf ''; ;;
        *) if (( $1 >= 1 && $1 <= 65535 )); then printf '%s' "$1"; else printf ''; fi;;
    esac
}
h3_port=$(parse_port "$ARG_H3")
reality_port=$(parse_port "$ARG_REALITY")
argo_port=${ARG_ARGO_PORT:-8001}
argo_protocol=${ARG_ARGO_PROTOCOL:-quic}
argo_domain=${ARG_ARGO_DOMAIN}
argo_token=${ARG_ARGO_TOKEN}

if [[ ! "$argo_port" =~ ^[0-9]+$ ]] || (( argo_port < 1 || argo_port > 65535 )); then
    die "Invalid Argo local port: ${argo_port}"
fi
if [[ "$argo_protocol" != quic && "$argo_protocol" != http2 && "$argo_protocol" != auto ]]; then
    die "Argo protocol must be quic, http2, or auto (got: ${argo_protocol})"
fi
enable_argo=false
if [[ -n "$argo_domain" && -n "$argo_token" ]]; then enable_argo=true; fi
if [[ -z "$h3_port" && -z "$reality_port" && "$enable_argo" == false ]]; then
    yellow "No enabled listener. Provide h3, reality, or both Argo domain and token."
    usage
    exit 0
fi
[[ $EUID -eq 0 ]] || die "Please run this script as root."

# Detect the init system before installing anything. Alpine 3.24.x uses OpenRC by default.
if [[ $(ps -p 1 -o comm= 2>/dev/null | tr -d ' ') == systemd ]] && command -v systemctl >/dev/null 2>&1; then
    INIT_SYSTEM=systemd
elif command -v rc-service >/dev/null 2>&1 && [ -x /sbin/openrc-run ]; then
    INIT_SYSTEM=openrc
else
    die "Unsupported init system: expected systemd or OpenRC."
fi

# Install runtime tools. Include certificates and OpenRC utilities on Alpine.
if command -v apk >/dev/null 2>&1; then
    apk add --no-cache bash curl unzip openssl coreutils util-linux ca-certificates openrc iptables >/dev/null || die "apk dependency installation failed"
elif command -v apt-get >/dev/null 2>&1; then
    apt-get update -y >/dev/null
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl unzip openssl coreutils util-linux ca-certificates iptables >/dev/null || die "apt dependency installation failed"
elif command -v dnf >/dev/null 2>&1; then
    dnf install -y curl unzip openssl coreutils util-linux ca-certificates iptables >/dev/null || die "dnf dependency installation failed"
elif command -v yum >/dev/null 2>&1; then
    yum install -y curl unzip openssl coreutils util-linux ca-certificates iptables >/dev/null || die "yum dependency installation failed"
else
    die "Unsupported package manager."
fi
for cmd in curl unzip openssl shuf; do command -v "$cmd" >/dev/null 2>&1 || die "Required command missing: $cmd"; done

# Stop old services cleanly before replacing the binaries/configuration.
if [[ "$INIT_SYSTEM" == systemd ]]; then
    systemctl stop xray cloudflared >/dev/null 2>&1 || true
else
    rc-service xray stop >/dev/null 2>&1 || true
    rc-service cloudflared stop >/dev/null 2>&1 || true
fi
pkill -x cloudflared >/dev/null 2>&1 || true
mkdir -p "$WORK_DIR"

case "$(uname -m)" in
    x86_64|amd64) XRAY_ARCH=64; CF_ARCH=amd64;;
    aarch64|arm64) XRAY_ARCH=arm64-v8a; CF_ARCH=arm64;;
    *) die "Unsupported architecture: $(uname -m)";;
esac

download_file "$WORK_DIR/xray.zip" "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${XRAY_ARCH}.zip" || die "Could not download Xray-core."
unzip -oq "$WORK_DIR/xray.zip" -d "$WORK_DIR" || die "Could not extract Xray-core."
rm -f "$WORK_DIR/xray.zip"
chmod 0755 "$WORK_DIR/xray"
if [[ "$enable_argo" == true ]]; then
    download_file "$WORK_DIR/cloudflared" "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CF_ARCH}" || die "Could not download cloudflared."
    chmod 0755 "$WORK_DIR/cloudflared"
fi

uuid=$(cat /proc/sys/kernel/random/uuid)
h3_path="${uuid}-xu"
argo_path="${uuid}-argo"
reality_sni=addons.mozilla.org
openssl ecparam -genkey -name prime256v1 -out "$WORK_DIR/private.key"
openssl req -new -x509 -days 3650 -key "$WORK_DIR/private.key" -out "$WORK_DIR/cert.pem" -subj "/CN=bing.com"
key_pair=$("$WORK_DIR/xray" x25519)
private_key=$(awk -F: '/PrivateKey/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}' <<<"$key_pair")
public_key=$(awk -F: '/Password/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}' <<<"$key_pair")
[[ -n "$private_key" && -n "$public_key" ]] || die "Failed to create Xray Reality keys."
short_id=$(date +%s%N | sha256sum | cut -c1-8)

inbounds=()
if [[ -n "$reality_port" ]]; then
    inbounds+=("{
      \"tag\":\"tcp-reality\",\"listen\":\"::\",\"port\":${reality_port},\"protocol\":\"vless\",
      \"settings\":{\"clients\":[{\"id\":\"${uuid}\",\"flow\":\"xtls-rprx-vision\"}],\"decryption\":\"none\"},
      \"streamSettings\":{\"network\":\"tcp\",\"security\":\"reality\",\"realitySettings\":{\"fingerprint\":\"chrome\",\"target\":\"${reality_sni}:443\",\"serverNames\":[\"${reality_sni}\"],\"privateKey\":\"${private_key}\",\"shortIds\":[\"${short_id}\"]}},
      \"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}")
fi
if [[ -n "$h3_port" ]]; then
    inbounds+=("{
      \"tag\":\"xhttp-h3\",\"listen\":\"::\",\"port\":${h3_port},\"protocol\":\"vless\",
      \"settings\":{\"clients\":[{\"id\":\"${uuid}\"}],\"decryption\":\"none\"},
      \"streamSettings\":{\"network\":\"xhttp\",\"security\":\"tls\",\"xhttpSettings\":{\"mode\":\"packet-up\",\"path\":\"/${h3_path}\"},\"tlsSettings\":{\"alpn\":[\"h3\"],\"certificates\":[{\"certificateFile\":\"${WORK_DIR}/cert.pem\",\"keyFile\":\"${WORK_DIR}/private.key\"}]}},
      \"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}")
fi
if [[ "$enable_argo" == true ]]; then
    inbounds+=("{
      \"tag\":\"xhttp-argo\",\"listen\":\"127.0.0.1\",\"port\":${argo_port},\"protocol\":\"vless\",
      \"settings\":{\"clients\":[{\"id\":\"${uuid}\"}],\"decryption\":\"none\"},
      \"streamSettings\":{\"network\":\"xhttp\",\"security\":\"none\",\"xhttpSettings\":{\"path\":\"/${argo_path}\",\"mode\":\"auto\"}},
      \"sniffing\":{\"enabled\":true,\"destOverride\":[\"http\",\"tls\",\"quic\"]}}")
fi
inbounds_json=$(IFS=,; printf '%s' "${inbounds[*]}")
cat > "$WORK_DIR/config.json" <<EOF
{
  "log":{"loglevel":"warning","error":"${WORK_DIR}/xray.log"},
  "inbounds":[${inbounds_json}],
  "outbounds":[{"tag":"direct","protocol":"freedom"}]
}
EOF
"$WORK_DIR/xray" run -test -config "$WORK_DIR/config.json" >/dev/null || die "Generated Xray config is invalid."

# Register and start Xray with the host's init system.
if [[ "$INIT_SYSTEM" == systemd ]]; then
    cat > /etc/systemd/system/xray.service <<EOF
[Unit]
Description=Xray Service
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
ExecStart=${WORK_DIR}/xray run -config ${WORK_DIR}/config.json
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable --now xray || die "Could not start Xray. Check: journalctl -u xray"
else
    cat > /etc/init.d/xray <<'EOF'
#!/sbin/openrc-run
description="Xray Service"
command="/etc/xray/xray"
command_args="run -config /etc/xray/config.json"
command_background="yes"
pidfile="/run/xray.pid"
depend() { need net; }
EOF
    chmod 0755 /etc/init.d/xray
    rc-update add xray default >/dev/null 2>&1 || true
    rc-service xray restart || die "Could not start Xray. Check: /var/log/messages"
fi

# Start Cloudflare Tunnel under systemd or OpenRC. OpenRC support is required on Alpine.
if [[ "$enable_argo" == true ]]; then
    connections=1
    [[ "$argo_protocol" == http2 ]] && connections=4
    if [[ "$INIT_SYSTEM" == systemd ]]; then
        cat > /etc/systemd/system/cloudflared.service <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network-online.target xray.service
Wants=network-online.target
[Service]
Type=simple
ExecStart=${WORK_DIR}/cloudflared tunnel --no-autoupdate --retries 5 --grace-period 1s --protocol ${argo_protocol} --ha-connections ${connections} run --token ${argo_token}
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable --now cloudflared || die "Could not start cloudflared. Check: journalctl -u cloudflared"
    else
        cat > /etc/init.d/cloudflared <<EOF
#!/sbin/openrc-run
description="Cloudflare Tunnel"
command="/etc/xray/cloudflared"
command_args="tunnel --no-autoupdate --retries 5 --grace-period 1s --protocol ${argo_protocol} --ha-connections ${connections} run --token ${argo_token}"
command_background="yes"
pidfile="/run/cloudflared.pid"
depend() { need net; }
EOF
        chmod 0755 /etc/init.d/cloudflared
        rc-update add cloudflared default >/dev/null 2>&1 || true
        rc-service cloudflared restart || die "Could not start cloudflared. Check: /var/log/messages"
    fi
fi

# Open only the direct inbound ports; the Argo inbound is loopback-only.
for port in "$h3_port" "$reality_port"; do
    [[ -n "$port" ]] || continue
    if command -v ufw >/dev/null 2>&1 && ufw status 2>/dev/null | grep -q 'Status: active'; then
        ufw allow "${port}/tcp" >/dev/null 2>&1 || true
        ufw allow "${port}/udp" >/dev/null 2>&1 || true
    fi
    if command -v iptables >/dev/null 2>&1; then
        iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || iptables -A INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null || true
        iptables -C INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null || iptables -A INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null || true
    fi
done

raw_ip=$(curl -4 -fsS --max-time 5 https://api.ipify.org 2>/dev/null || curl -6 -fsS --max-time 5 https://api64.ipify.org 2>/dev/null || true)
[[ -n "$raw_ip" ]] || raw_ip=YOUR_SERVER_IP
[[ "$raw_ip" == *:* ]] && server_ip="[${raw_ip}]" || server_ip=$raw_ip
: > "$WORK_DIR/url.txt"
if [[ -n "$reality_port" ]]; then
    printf 'vless://%s@%s:%s?encryption=none&security=reality&sni=%s&fp=chrome&pbk=%s&sid=%s&type=tcp&flow=xtls-rprx-vision#Reality\n' "$uuid" "$server_ip" "$reality_port" "$reality_sni" "$public_key" "$short_id" >> "$WORK_DIR/url.txt"
fi
if [[ -n "$h3_port" ]]; then
    printf 'vless://%s@%s:%s?encryption=none&security=tls&sni=bing.com&alpn=h3&fp=chrome&type=xhttp&mode=packet-up&path=/%s&allowInsecure=1#H3-XHTTP\n' "$uuid" "$server_ip" "$h3_port" "$h3_path" >> "$WORK_DIR/url.txt"
fi
if [[ "$enable_argo" == true ]]; then
    # Use the configured hostname as the endpoint instead of hard-coded CF front domains.
    printf 'vless://%s@%s:443?encryption=none&security=tls&alpn=h2&sni=%s&fp=chrome&type=xhttp&mode=auto&host=%s&path=/%s#Argo-XHTTP-H2\n' "$uuid" "$argo_domain" "$argo_domain" "$argo_domain" "$argo_path" >> "$WORK_DIR/url.txt"
    printf 'vless://%s@%s:443?encryption=none&security=tls&alpn=h3&sni=%s&fp=chrome&type=xhttp&mode=auto&host=%s&path=/%s#Argo-XHTTP-H3\n' "$uuid" "$argo_domain" "$argo_domain" "$argo_domain" "$argo_path" >> "$WORK_DIR/url.txt"
fi
base64_str=$(base64 < "$WORK_DIR/url.txt" | tr -d '\n\r')
green "Deployment complete (${INIT_SYSTEM}). Base64 node links:"
printf '%s\n' "$base64_str"
if [[ "$enable_argo" == true ]]; then
    yellow "Cloudflare Zero Trust Public Hostname must route ${argo_domain} to http://127.0.0.1:${argo_port} (HTTP, not HTTPS). Verify the tunnel token and DNS route if the hostname is still unreachable."
fi
printf '\nUninstall: bash <(curl -Ls https://raw.githubusercontent.com/eishare/Xray-go/main/uninstall.sh)\n'
