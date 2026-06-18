# 🚀 京东云雅典娜 AX6600 定制 OpenWrt 固件 (Cloud Build + NSS Acceleration)

基于 OpenWrt / ImmortalWrt 源码定制的路由器固件，专门为京东云雅典娜 AX6600 (RE-CS-02) 以及 IPQ60xx 平台优化，提供丰富的硬件加速驱动和网络应用。

[👉 进入项目主页](https://github.com/King-Sager2333/Openwrt-AX6600)

---

## ⭐ 项目特点

- 🔥 **云编译构建** - 基于 GitHub Actions 完全自动化编译
- 📦 **官方支持** - 完美适配京东云雅典娜AX6600（RE-CS-02）
- 🚀 **开箱即用** - 预装常用网络工具与各类实用插件
- ⚡ **硬件加速** - 原生支持 NSS 硬件加速引擎
- 🌐 **性能优化** - 显著提升 NAT/转发/吞吐性能
- 🔄 **源码同步** - 自动跟进 OpenWrt/ImmortalWrt 最新上游
- 🧩 **灵活定制** - 支持自定义编译配置和插件

---

## 📥 快速开始

### 1️⃣ 下载固件
🎯 **[👉 点击下载最新固件](https://github.com/King-Sager2333/Openwrt-AX6600/releases/latest)**

所有编译产物都在 Releases 页面发布，选择最新版本下载。

📦 **刷机相关文件（Bootloader / 工具 / 备用固件）**
👉 **[点击下载刷机文件](https://github.com/ones20250/Openwrt-AX6600/releases/tag/Router-Flashing-Files)**

---

## 🛠️ 刷机指南

> ⚠️ **重要提示：** 以下操作涉及 U-Boot 和分区修改，**请务必先备份重要数据**，谨慎操作！

### 详细教程
📖 **[完整刷机图文教程 →](https://blog.waynecommand.com/post/athena-re-cs-02.html)**（推荐新手参考）

### 刷机步骤

1. **启用 SSH 访问**
   - 进入旧版本固件管理后台
   - 启用 SSH 服务

2. **备份分区**（二选一）
   - 通过 SSH 备份分区数据
   - 或使用 TTL 串口备份（更安全）

3. **刷入 U-Boot**
   - 安装不死 U-Boot（防砖）
   - 更新双分区 GPT 分区表

4. **创建存储分区**
   - 新建 storage 分区
   - 恢复跑分分区数据

5. **刷入固件**
   - 从 Releases 下载最新固件
   - 通过 U-Boot Web 界面刷入

---

## 📦 编译包含的组件及包说明

以下是该固件编译时默认集成的核心包及插件，按功能进行分类和说明：

### 🌐 LuCI 界面与应用插件 (LuCI Apps & Themes)
- **luci-base / luci-lib-base / luci-lib-ipkg / luci-lua-runtime / luci-compat**: LuCI Web 界面核心及运行库，提供基础界面支持。
- **luci-theme-argon**: 广受欢迎的 Argon 主题，提供现代化美观的路由器后台界面。
- **luci-i18n-argon-zh-cn / luci-i18n-base-zh-cn / luci-i18n-firewall-zh-cn**: 提供基础界面及 Argon 主题的简体中文支持。
- **luci-app-adguardhome / luci-i18n-adguardhome-zh-cn**: AdGuard Home 界面支持，用于全网络去广告和隐私保护。
- **luci-app-arpbind**: IP/MAC 绑定工具界面。
- **luci-app-athena-led**: 专为雅典娜定制的 LED 点阵屏控制插件。
- **luci-app-autoreboot**: 定时重启插件，可配置路由器定时重启以保持性能。
- **luci-app-dockerman / luci-i18n-dockerman-zh-cn**: Docker 容器管理 Web 界面。
- **luci-app-filebrowser-go / luci-i18n-filebrowser-go-zh-cn**: FileBrowser 的 Web 界面，提供基于网页的文件管理服务。
- **luci-app-airplay2 / luci-i18n-airplay2-zh-cn**: AirPlay 2 接收端插件，使路由器支持 Apple 设备的音频投屏。
- **luci-app-firewall4**: 防火墙 (Firewall4) 控制界面。
- **luci-app-mountd**: 自动挂载工具的 Web 界面。
- **luci-app-partexp**: 物理分区一键扩容插件，非常适合雅典娜这类带有大内置存储的设备。
- **luci-app-passwall / luci-i18n-passwall-zh-cn**: 强大的网络代理客户端，支持丰富的代理协议。
- **luci-app-samba4**: SMB 网络共享插件界面，用于局域网文件共享。
- **luci-app-sentinel**: 哨兵网络监控/认证相关应用。
- **luci-app-wireless-regdb**: 无线区域设置调整，突破 Wi-Fi 限制。
- **luci-app-wolplus**: 增强版局域网唤醒 (WOL) 工具界面。
- **luci-proto-relay**: 提供中继协议支持界面。

### 🚀 核心驱动与硬件加速模块 (Kernel Modules & NSS)
- **kmod-qca-nss-drv / kmod-qca-nss-ecm**: 高通 NSS 硬件加速核心驱动。
- **kmod-qca-nss-drv-bridge-mgr**: NSS 桥接管理驱动。
- **kmod-qca-nss-drv-map-t**: NSS MAP-T 硬件加速驱动。
- **kmod-qca-nss-drv-pppoe**: NSS PPPoE 拨号硬件加速驱动。
- **kmod-qca-nss-drv-qdisc**: NSS 队列调度硬件加速驱动。
- **kmod-qca-nss-drv-vlan-mgr**: NSS VLAN 管理驱动。

### 🔌 USB、网络与外设驱动 (USB, Network & Peripherals)
- **kmod-usb-core / kmod-usb3 / kmod-usb-dwc3 / kmod-usb-xhci**: USB 核心支持和 USB 3.0 / XHCI 驱动。
- **kmod-usb-storage / kmod-usb-storage-extras / kmod-usb-storage-uas**: USB 大容量存储及 UAS 高速传输协议支持。
- **kmod-usb-net / kmod-usb-net-asix / kmod-usb-net-asix-ax88179 / kmod-usb-net-rtl8152**: 各种主流 USB 网卡（如 RTL8152/AX88179）的驱动程序。
- **kmod-usb-net-qmi-wwan / kmod-usb-net-qmi-wwan-fibocom / kmod-usb-net-qmi-wwan-quectel**: 支持 4G/5G 模块的 QMI 拨号驱动。
- **kmod-mmc / kmod-sdhci / kmod-sdhci-msm**: eMMC 及 SD 卡存储控制器驱动。
- **kmod-fs-ext4 / kmod-fs-ntfs3**: 提供 ext4 文件系统及原生高性能 NTFS 读写驱动。
- **kmod-sound-core**: 核心音频支持。
- **usbutils / usb-modeswitch**: USB 设备调试和模式切换工具（如用于 4G 拨号卡）。

### 🛠️ 系统与磁盘工具 (System & Disk Tools)
- **autocore**: CPU 温度、频率状态获取，核心信息展示模块。
- **cpufreq**: CPU 频率调节支持，用于性能或节能调度。
- **athena-led-control**: 京东云雅典娜 LED 点阵屏的核心控制程序。
- **automount / block-mount**: 实现 U 盘及磁盘分区的自动识别与挂载。
- **e2fsprogs / resize2fs / tune2fs**: ext2/ext3/ext4 文件系统管理、检查和在线扩容工具包。
- **fdisk / sfdisk / gdisk / cgdisk**: 经典的 MBR 和 GPT 磁盘分区工具。
- **blkid / lsblk**: 块设备（磁盘）属性和结构查询工具。
- **dmesg / htop**: 内核日志查看器及交互式进程资源查看器。

### 🛡️ 网络协议与安全工具 (Network & Security)
- **firewall4**: OpenWrt 最新基于 nftables 的防火墙管理程序。
- **kmod-nft-core / kmod-nft-bridge / kmod-nft-fib / kmod-nft-socket / kmod-nft-tproxy / kmod-nft-xfrm**: nftables 防火墙所需的内核支持模块（含透明代理相关）。
- **kmod-tun / kmod-veth**: 虚拟隧道及以太网接口支持（常用于 VPN 和 Docker）。
- **kmod-wireguard**: WireGuard 虚拟专用网络内核级支持。
- **adguardhome**: AdGuard Home 核心程序。
- **xray-core**: Xray 核心客户端，为 PassWall 等代理工具提供底层协议支持。
- **curl**: 强大的命令行 URL 传输工具。
- **iperf3**: 用于网络吞吐量性能测试的标准工具。
- **ip-full / iwinfo**: 增强的网络配置命令集及无线设备信息查询工具。
- **openssl-util / libopenssl / libopenssl-conf**: OpenSSL 加密套件与库。
- **openssh-keygen / openssh-sftp-server**: 安全秘钥生成工具和用于 SSH 文件传输的 SFTP 服务端。
- **iptasn**: ASN（自治系统号）处理相关工具。
- **kmod-dsa**: 分布式交换机架构支持。
- **kmod-inet-diag**: 网络连接诊断相关内核模块。
- **shairport-sync-openssl**: Shairport Sync AirPlay 2 服务核心。

### 🐳 Docker 容器服务 (Docker)
- **dockerd / docker-compose**: Docker 引擎核心守护进程及容器编排编配工具，使路由器具备运行 Linux 容器的能力。

---

## 📂 项目结构

| 目录/文件 | 用途 | 说明 |
|----------|------|------|
| `.github/workflows/` | CI/CD 自动编译 | 定义 GitHub Actions 工作流，实现云端自动构建 |
| `scripts/` | 编译脚本 | 包含编译前置处理、自定义配置等辅助脚本 |
| `config/` | 编译配置 | 存放 OpenWrt `.config` 配置文件 |

---

## 🔗 上游源码与依赖

### 📦 OpenWrt 源码仓库

| 版本 | 仓库地址 | 说明 |
|------|---------|------|
| **官方版** | [immortalwrt/immortalwrt](https://github.com/immortalwrt/immortalwrt.git) | ImmortalWrt 官方仓库 |
| **高通专用版** | [ones20250/immortalwrt_ipq](https://github.com/ones20250/immortalwrt_ipq.git) | IPQ 平台优化版本 |

### 🔧 U-Boot 固件仓库

| 平台 | 仓库地址 | 说明 |
|------|---------|------|
| **eMMC 版本** | [chenxin527/uboot-ipq60xx-emmc-build](https://github.com/chenxin527/uboot-ipq60xx-emmc-build) | eMMC 存储设备专用 |
| **NOR Flash 版本** | [chenxin527/uboot-ipq60xx-nor-build](https://github.com/chenxin527/uboot-ipq60xx-nor-build) | NOR Flash 存储设备专用 |

---

## 🚀 自定义编译

### 修改编译配置

编辑 `config/.config` 文件，按需调整编译选项：

```bash
# 克隆仓库
git clone https://github.com/King-Sager2333/Openwrt-AX6600.git
cd Openwrt-AX6600

# 编辑配置文件
edit config/.config

# 提交更改（可选）
git commit -am "feat: 更新编译配置"
git-push origin main
```

---

## 🔐 安全建议

### ⚠️ 刷机前必读

1. **备份所有数据**
   ```bash
   # SSH 连接到设备
   ssh root@192.168.1.1

   # 备份整个 U-Boot 分区
   dd if=/dev/mtd0 of=/tmp/uboot.bin

   # 备份分区表
   dd if=/dev/mtd1 of=/tmp/partition_table.bin
   ```
2. **验证文件完整性**
   ```bash
   # 下载固件和校验和文件
   # 验证 SHA256
   sha256sum -c firmware.bin.sha256
   ```
3. **准备恢复方案**
   - 保留 TTL 串口工具
   - 准备原厂固件备份
   - 了解救砖流程

### 🛡️ 常见风险及预防

| 风险 | 症状 | 预防方法 |
|------|------|---------|
| **U-Boot 错误** | 设备无法启动 | 使用不死 U-Boot，备份原件 |
| **分区错误** | 系统无法识别 | 使用正确的 GPT 分区表 |
| **断电** | 刷机中断 | 使用 UPS 或稳定电源 |
| **固件损坏** | 开机无响应 | 验证 SHA256 后再刷入 |

## ⚠️ 免责声明

刷机有风险，操作需谨慎。
本项目固件仅供学习与研究使用，请确认设备型号匹配并提前备份数据。
因刷机造成的设备损坏或数据丢失，作者不承担任何责任。
