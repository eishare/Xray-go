# 🛡️ X-Shield (Xray 极速/防QoS/抗封锁 组合方案)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20VPS-blue)](https://www.linux.org)
[![Protocol](https://img.shields.io/badge/Xray-Core-orange)](https://github.com/XTLS/Xray-core)

一个现代化、高性能的 **Xray** 一键部署与管理脚本。本方案专为高强度网络审查环境设计，完美整合了 **XHTTP（H2/H3）**、**Cloudflare Argo 隧道** 以及 **VLESS-TCP-REALITY**，兼顾极端抗封锁能力与极致访问速度。

---

## 🚀 核心特性

*   **⚡ XHTTP H3 直连**：利用最新 XHTTP 传输协议结合 HTTP/3（QUIC），实现极低延迟与高并发吞吐。
*   **☁️ Cloudflare Argo 智能隧道**：支持 XHTTP 走 H2/H3 协议套用 Argo 隧道，实现原生 IP 隐藏、全球 CDN 加速及零端口暴露。
*   **🔒 VLESS-TCP-REALITY**：无域名、免备案的王牌抗封锁组合，完美伪装成合法 TLS 流量，免疫主动探测。
*   **🛠️ 自动化部署**：纯 Shell 脚本编写，一键自动安装依赖、配置内核、申请证书与生成节点信息。

---

## 📦 架构组合说明

| 协议组合 | 核心优势 | 适用场景 |
| :--- | :--- | :--- |
| **XHTTP + H3 (QUIC)** | 速度极快，多路复用，抗 UDP 限速 | 优质网络环境下的主力直连通道 |
| **XHTTP + Argo 隧道** | 隐藏真实 IP，穿透性极强，支持 CDN | IP 被墙或严苛企业/校园网络环境 |
| **VLESS + TCP + REALITY** | 无域名要求，完美防封锁，伪装度 100% | 高抗封锁需求、追求稳定长期连线 |

---
## 💻 系统支持

本脚本适配主流 Linux 发行版，建议在全新干净的系统上运行：

| 系统平台 | 最低版本要求 | 状态 / 备注 |
| :--- | :--- | :--- |
| **Ubuntu** | 20.04+ | ✅ 完美支持（推荐） |
| **Debian** | 11+ | ✅ 完美支持（推荐） |
| **CentOS** | 7 / 8 / 9 Stream | ✅ 支持（自动适配防火墙） |
| **Alpine** | 3.16+ | ✅ 支持（基于 musl 静态编译运行） |
## ⚙️ 快速安装
---
使用 SSH 登录您的 Linux VPS（推荐 Ubuntu 20.04+ / Debian 11+），以 `root` 权限运行以下安装命令：

```bash
bash <(curl -Ls [https://raw.githubusercontent.com/您的用户名/仓库名/main/install.sh](https://raw.githubusercontent.com/您的用户名/仓库名/main/install.sh))
