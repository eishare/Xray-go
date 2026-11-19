<div style="display: flex; align-items: center; gap: 24px; margin: 30px 0 20px 0;">
  <img src="https://github.com/eishare/X-Shield/blob/main/logo.png" alt="Xray-go Logo" width="100" style="display: block; border-radius: 14px; flex-shrink: 0; border: none;">
  <div style="font-size: 34px; font-weight: 900; line-height: 1.25; color: #24292e;">
  </div>
</div>
<br>

## Xray-go 极速/防QoS/抗封锁部署方案（VPS 服务器版）
**XHTTP（H3直连）** / **XHTTP-Argo 隧道** / **VLESS-TCP-REALITY Vision**

---

## 🚀 核心特性

- **XHTTP H3 直连**：使用 HTTP/3（QUIC）传输。
- **XHTTP + Argo**：通过 Cloudflare Tunnel 转发至本机 Xray 服务，隐藏源站 IP。
- **VLESS-TCP-REALITY Vision**：无需域名的备用连接方式。
- **Alpine/OpenRC 支持**：安装脚本支持 Alpine Linux 3.24.4 的 OpenRC 服务管理。

## 💻 系统支持

| 系统平台 | 版本要求 | 服务管理 |
| :--- | :--- | :--- |
| Ubuntu | 20.04+ | systemd |
| Debian | 11+ | systemd |
| CentOS | 7 / 8 / 9 Stream | systemd |
| Alpine Linux | 3.16+（含 3.24.4） | OpenRC |

## ⚙️ 快速安装

以 `root` 登录服务器。Alpine 3.24.4 可先安装 Bash、curl：

```sh
apk update && apk add --no-cache bash curl
```

下载并运行此分支的部署脚本（将域名、Token 替换为自己的 Cloudflare Tunnel 配置）：

```sh
curl -fsSL -o /tmp/xray-go.sh https://raw.githubusercontent.com/lihuabing1/Xray-go/fix/alpine-argo-openrc/xray-go.sh
bash /tmp/xray-go.sh reality"n" h3"y" protocol"quic" port"8001" domain"tunnel.example.com" token"YOUR_TUNNEL_TOKEN"
```

若不启用 Argo，可将 `domain` 和 `token` 留空，或只配置 H3/Reality：

```sh
bash /tmp/xray-go.sh reality"n" h3"y"
```

### 参数说明

- `reality"n"`：不启用 Reality；也可写 `reality"12345"` 指定端口。
- `h3"y"`：启用 H3 并随机分配端口；也可写 `h3"12345"` 指定端口，或 `h3"n"` 禁用。
- `protocol"quic"`：Cloudflare Tunnel 到源站的协议，可选 `quic`、`http2` 或 `auto`。
- `port"8001"`：Xray 在本机监听的 Argo 回源端口。
- `domain"tunnel.example.com"`：Cloudflare Tunnel 配置的完整 Public Hostname。
- `token"YOUR_TUNNEL_TOKEN"`：该 Tunnel 的 Token。请勿公开分享。

### Cloudflare Tunnel 回源设置（Argo 域名无法连接时请检查）

在 Cloudflare Zero Trust 的 Tunnel 中为该主机名配置 Public Hostname/DNS 路由，并将 Service 指向：

```text
http://127.0.0.1:8001
```

端口必须与脚本里的 `port"8001"` 一致；回源协议选择 **HTTP**，不要选 HTTPS。确认 Tunnel Token 属于该 Tunnel，并且主机名已绑定到它。部署后可在 Alpine 上检查服务状态：

```sh
rc-service xray status
rc-service cloudflared status
```

Argo 域名的 DNS 和 Cloudflare Tunnel 路由需要在 Cloudflare 侧正确配置；仅填写域名和 Token 不会自动创建主机名路由。

## 🗑️ 卸载

```sh
curl -fsSL -o /tmp/xray-uninstall.sh https://raw.githubusercontent.com/lihuabing1/Xray-go/fix/alpine-argo-openrc/uninstall.sh
bash /tmp/xray-uninstall.sh
```

---

<details>
<summary><b>⚖️ 免责声明 / Disclaimer</b></summary>

1. 本项目仅供网络研究、技术交流与学习使用。请遵守当地法律法规及相关平台服务条款。
2. 使用者需自行承担使用本项目产生的责任与风险。
3. 因违规使用导致的账号封禁、数据丢失或其他损失，由使用者自行承担。

</details>

---

### 📈 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=eishare/Xray-go&type=Date)](https://star-history.com/#eishare/Xray-go&Date)
