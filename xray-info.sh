#!/bin/bash

export LANG=en_US.UTF-8
green() { echo -e "\e[1;32m$1\033[0m"; }
yellow() { echo -e "\e[1;33m$1\033[0m"; }
red() { echo -e "\e[1;91m$1\033[0m"; }

work_dir="/etc/xray"
config_file="${work_dir}/config.json"
url_file="${work_dir}/url.txt"

# 1. 检查 Xray 是否安装及配置文件是否存在
if [ ! -f "$config_file" ]; then
    red "错误：未检测到 Xray 配置文件，请确认是否已部署！"
    exit 1
fi

green "=========================================================================================="
green " Xray 节点运行状态与链接一键查询工具"
green "=========================================================================================="

# 2. 检查核心服务运行状态
if systemctl is-active --quiet xray; then
    green " [√] Xray 服务状态: 正在运行 (Running)"
else
    red " [×] Xray 服务状态: 未运行或已停止"
fi

if systemctl list-unit-files | grep -q "cloudflared.service"; then
    if systemctl is-active --quiet cloudflared; then
        green " [√] Cloudflared Argo 隧道状态: 正在运行 (Running)"
    else
        yellow " [-] Cloudflared Argo 隧道状态: 已安装但未运行"
    fi
fi

echo "------------------------------------------------------------------------------------------"

# 3. 检查本地是否直接存有历史 url.txt，有则直接输出，无则提示
if [ -f "$url_file" ] && [ -s "$url_file" ]; then
    green "【本地保存的节点明细链接】："
    cat "$url_file"
    echo "------------------------------------------------------------------------------------------"
    
    # 重新生成并打印 Base64 编码
    base64_str=$(cat "$url_file" | base64 | tr -d '\n' | tr -d '\r')
    green "【Base64 订阅链接】："
    yellow "$base64_str"
else
    yellow "提示：未找到历史 url.txt 缓存文件，请重新运行部署脚本或检查 /etc/xray 目录。"
fi

green "=========================================================================================="
