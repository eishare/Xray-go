# 🛡️ X-Shield (Xray-XHTTP 极速/防QoS/抗封锁 组合方案)

<p align="left">
  <img src="https://img.shields.io/badge/Ubuntu-20.04%2B-E95420?style=flat-square&logo=ubuntu&logoColor=white" alt="Ubuntu">
  <img src="https://img.shields.io/badge/Debian-11%2B-A81D33?style=flat-square&logo=debian&logoColor=white" alt="Debian">
  <img src="https://img.shields.io/badge/CentOS-7%2F8%2F9-26252D?style=flat-square&logo=centos&logoColor=white" alt="CentOS">
  <img src="https://img.shields.io/badge/Alpine-Linux-0D5BE1?style=flat-square&logo=alpine&logoColor=white" alt="Alpine">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="License">
</p>

 **Xray-XHTTP** 一键部署与管理脚本。为高强度网络审查环境设计，整合了 **XHTTP（H3直连）**、**XHTTP-Argo 双模UDP隧道** 以及 **VLESS-TCP-REALITY Vision**，兼顾极速+极端抗封锁能力。

---

## 🚀 核心特性

*   **⚡ XHTTP H3 直连**：上下行流量分离，结合 HTTP/3（QUIC） 标准UDP，实现极低延迟与高并发吞吐，速度对标TUIC协议，但不易被运营商QoS。
*   **☁️ Argo 双模UDP隧道**：隧道protocol选择quic，客户端设置H3，Argo隧道全段跑UDP！同时实现原生 IP 隐藏、全球 CDN 加速及零端口暴露。
*   **🔒 VLESS-TCP-REALITY Vision**：经典抗封锁协议，完美伪装合法 TLS 流量，免疫主动探测。

---

## 📦 适用说明

| 协议组合 | 核心优势 | 适用场景 |
| :--- | :--- | :--- |
| **XHTTP + H3 (QUIC)** | 速度极快，多路复用，抗 UDP 限速 | 优质网络环境下的主力直连通道 |
| **XHTTP + Argo 双模UDP隧道** | UDP极速，隐藏真实 IP，穿透性极强，支持 CDN | IP 被墙或严苛企业/校园网络环境 |
| **VLESS + TCP + REALITY** | 无域名要求，完美防封锁，伪装度 100% | 受TCP拥塞影响，建议作为备选 |

---
## 💻 系统支持


| 系统平台 | 版本要求 | 状态 / 备注 |
| :--- | :--- | :--- |
| **Ubuntu** | 20.04+ | ✅ 完美支持（推荐） |
| **Debian** | 11+ | ✅ 完美支持（推荐） |
| **CentOS** | 7 / 8 / 9 Stream | ✅ 支持（自动适配防火墙） |
| **Alpine** | 3.16+ | ✅ 支持（基于 musl 静态编译运行） |

## ⚙️ 一键安装
---
使用 SSH 登录，以 `root` 权限运行以下指令（如需设置变量，建议先复制到记事本，再编辑使用）：

```bash
bash <(curl -Ls [https://raw.githubusercontent.com/eishare/X-Shield/main/X-Shield.sh](https://raw.githubusercontent.com/eishare/X-Shield/main/X-Shield.sh)) 
