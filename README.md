# 🚀 京东云雅典娜 AX6600 定制 OpenWrt 固件

本项目为基于 OpenWrt / ImmortalWrt 源码定制的路由器固件，专门为京东云雅典娜 AX6600 (RE-CS-02) 以及 IPQ60xx 平台优化，提供丰富的硬件加速驱动和网络应用。

[👉 进入项目主页](https://github.com/King-Sager2333/Openwrt-AX6600)

---

## 📦 编译包含的组件及包说明

以下是该固件编译时默认集成的核心包及插件，按功能进行分类和说明：

### 🌐 LuCI 界面与应用插件 (LuCI Apps & Themes)
- **luci-theme-argon**: 广受欢迎的 Argon 主题，提供现代化美观的路由器后台界面。
- **luci-app-adguardhome**: AdGuard Home 界面支持，用于全网络去广告和隐私保护。
- **luci-app-athena-led**: 专为雅典娜定制的 LED 点阵屏控制插件。
- **luci-app-autoreboot**: 定时重启插件，可配置路由器定时重启以保持性能。
- **luci-app-dockerman**: Docker 容器管理 Web 界面。
- **luci-app-filebrowser-go**: FileBrowser 的 Web 界面，提供基于网页的文件管理服务。
- **luci-app-airplay2**: AirPlay 2 接收端插件，使路由器支持 Apple 设备的音频投屏。
- **luci-app-partexp**: 物理分区一键扩容插件，非常适合雅典娜这类带有大内置存储的设备。
- **luci-app-passwall**: 强大的网络代理客户端，支持丰富的代理协议。

### 🚀 核心驱动与硬件加速模块 (Kernel Modules & NSS)
- **kmod-qca-nss-drv / kmod-qca-nss-ecm**: 高通 NSS 硬件加速核心驱动，显著提升网络吞吐量。
- **kmod-qca-nss-drv-pppoe**: NSS PPPoE 拨号硬件加速驱动。
- **kmod-sound-core**: 核心音频支持，用于 AirPlay 等多媒体投屏服务。

### 🐳 Docker 容器服务 (Docker)
- **dockerd / docker-compose**: Docker 引擎核心守护进程及容器编排编配工具，使路由器具备运行 Linux 容器的能力。
