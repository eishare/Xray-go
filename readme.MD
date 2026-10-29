<div style="display: flex; align-items: center; gap: 24px; margin: 30px 0 20px 0;">
  <img src="https://github.com/eishare/X-Shield/blob/main/logo.png" alt="Xray-go Logo" width="100" style="display: block; border-radius: 14px; flex-shrink: 0; border: none;">
  <div style="font-size: 34px; font-weight: 900; line-height: 1.25; color: #24292e;">
  </div>
</div>
<br>

**Xray-go 极速/防QoS/抗封锁 部署方案**：
<br>
**XHTTP（H3直连）**/ **XHTTP-Argo 双模UDP隧道** / **VLESS-TCP-REALITY Vision**

<br>

<p align="left" style="margin: 20px 0 16px 0;">
  <img src="https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=flat-square&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Debian-11%2B-A81D33?style=flat-square&logo=debian&logoColor=white" alt="Debian">
  <img src="https://img.shields.io/badge/CentOS-7%2F8%2F9-26252D?style=flat-square&logo=centos&logoColor=white" alt="CentOS">
  <img src="https://img.shields.io/badge/Alpine-Linux-0D5BE1?style=flat-square&logo=alpine&logoColor=white" alt="Alpine">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="License">
</p>


---

## 🚀 核心特性

*   **⚡ XHTTP H3 直连**：上下行流量分离，使用 HTTP/3 标准UDP，实现极低延迟与高并发吞吐。速度对标TUIC协议，但不易被运营商QoS。
*   **☁️ Argo 双模UDP隧道**：隧道protocol选择quic，客户端设置H3，让Argo隧道全段跑UDP！服务器 IP 隐藏、Cloudflare CDN 加速及零端口暴露。
*   **🔒 VLESS-TCP-REALITY Vision**：经典抗封锁协议，完美伪装 TLS 流量，Vision流控，免疫主动探测。

---

## 📦 说明

| 协议组合 | 核心优势 | 适用场景 |
| :--- | :--- | :--- |
| **XHTTP + H3 (QUIC)** | ✅HTTP/3 标准 UDP 传输，不易被QoS | 主力高速直连协议 |
| **XHTTP + Argo 双模UDP隧道** | ✅Argo隧道变身UDP协议！隐藏真实 IP，内网穿透，支持优选域名/ip | IP 被墙或极限封锁网络环境 |
| **VLESS + TCP + REALITY Vision** | ✅无域名要求，完美伪装防封锁 | 晚高峰易受TCP拥塞影响，建议备选 |

---
## 💻 系统支持


| 系统平台 | 版本要求 | 状态 / 备注 |
| :--- | :--- | :--- |
| **Ubuntu** | 20.04+ | ✅ 支持 |
| **Debian** | 11+ | ✅ 支持 |
| **CentOS** | 7 / 8 / 9 Stream | ✅ 支持（自动适配防火墙） |
| **Alpine** | 3.16+ | ✅ 支持（基于 musl 静态编译运行） |
<br>

**✅已添加Cloudflare代理下载，完美支持IPv6机型**
<br>

## ⚙️ 快速安装

使用 SSH 登录服务器，以 `root` 权限运行以下指令（如需设置变量，建议先复制到记事本中再修改）：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/eishare/X-Shield/main/X-Shield.sh)
 ```
末尾"变量"设置说明：
<br>
reality"y" = 部署+随机端口；reality"12345" = 部署在12345端口；reality"n" = 放弃部署；
<br>
argo protocol"quic" = 默认部署quic隧道+1条连接；可改成http2，默认4条连接；
<br>
port"8001" = 8001 与Cloudflare Tunnel 服务URL末尾端口一致
<br>
domain"" = Cloudflare Tunnel 路由设置的完整主机名
<br>
token"" = 固定隧道 Token
<br>
---

 ## 🗑️ 一键卸载

部署方案未达预期？请使用以下指令卸载：

```bash
bash <(curl -Ls https://raw.githubusercontent.com/eishare/X-Shield/main/X-Shield.sh) uninstall
```
