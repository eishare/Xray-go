#!/bin/bash

# 1. 停止并禁用 Systemd 或 OpenRC 服务
systemctl disable --now xray 2>/dev/null
rm -f /etc/systemd/system/xray.service
systemctl daemon-reload 2>/dev/null

rc-service xray stop 2>/dev/null
rc-update del xray default 2>/dev/null
rm -f /etc/init.d/xray

# 2. 强行终止残留进程
pkill -9 -f xray 2>/dev/null
pkill -9 -f cloudflared 2>/dev/null

# 3. 删除安装目录与所有文件
rm -rf /etc/xray

echo -e "\033[1;32mXray 及相关组件已卸载完成，感谢您的使用！\033[0m"
