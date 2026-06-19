# 🚀 OpenWrt AX6600 / IPQ60xx 固件构建项目

基于 OpenWrt / ImmortalWrt 的定制固件，专门为 JDCloud RE-CS-02（京东云雅典娜 AX6600）打造。

**当前版本前缀：`King-Sager2333`**

本项目主要利用 GitHub Actions 进行云端自动化编译，在原有的基础上集成了常用且强大的网络插件与工具，并优化了底层性能与内存管理策略。

---

## ⭐ 项目特点

- 🔥 **完全云编译构建** - 通过 GitHub Actions 手动触发编译，无需在本地配置繁杂的编译环境。
- 📦 **预装丰富的插件** - 集成了日常网络环境中常用的过滤、代理、多媒体和文件管理工具。
- ⚡ **原生 NSS 硬件加速支持** - 显著提升路由器的数据转发与吞吐能力，降低 CPU 负载。
- 🌐 **系统安全与性能调优** - 代码经过优化与审查，移除了冗余逻辑，提升了运行的稳定性与安全性。
- 🧩 **全量中文支持** - 所有主要插件均附带简体中文语言包，极大地降低了使用门槛。

---

## 🛠️ 集成的核心插件列表

以下是在固件中预先编译好的核心插件及其功能说明：

| 插件名称 (LuCI App) | 语言包 | 功能说明 |
| ------------------- | ------ | -------- |
| **AirPlay 2** (`luci-app-airplay2`) | `luci-i18n-airplay2-zh-cn` | 苹果生态无线音频投射接收端，支持让音箱变身 AirPlay 设备。 |
| **FileBrowser** (`luci-app-filebrowser`) | `luci-i18n-filebrowser-zh-cn` | 轻量级、直观的 Web 文件管理器，方便通过浏览器直接管理路由器上的存储文件。 |
| **Passwall** (`luci-app-passwall`) | `luci-i18n-passwall-zh-cn` | 强大的科学上网代理客户端，支持多节点、分流及高阶网络路由。 |
| **AdGuard Home** (`luci-app-adguardhome`) | `luci-i18n-adguardhome-zh-cn` | 全局广告拦截与隐私保护工具，通过自建 DNS 服务器阻止跟踪器和广告域名。 |
| **Dockerman** (`luci-app-dockerman`) | `luci-i18n-dockerman-zh-cn` | 可视化 Docker 容器管理工具，方便在路由器上轻松部署和管理 Docker 应用。 |
| **Athena LED** (`luci-app-athena-led`) | 驱动自带 | 针对京东云雅典娜专属适配的点阵屏控制插件，支持自定义显示网络状态和信息。 |
| **Argon Theme** (`luci-theme-argon`) | `luci-i18n-argon-config-zh-cn` | 美观且功能丰富的现代化 LuCI 界面主题，附带可视化的主题设置模块。 |

---

## 🚀 如何触发云编译？

为了安全起见，自动编译触发条件已被移除，只能由仓库的所有者手动触发编译。

1. 进入当前 GitHub 仓库的主页。
2. 点击页面上方的 **Actions** 选项卡。
3. 在左侧工作流列表中，点击 **`QCA-ALL`** (用于完整构建)。
4. 在右侧点击 **Run workflow** 按钮。
5. （可选）在弹出的菜单中，你可以在 `PACKAGE` 框中填入你想额外增加的插件列表。
6. 点击绿色的 **Run workflow** 确认执行。
7. 编译通常需要 1 到 2 小时。完成后，在 QCA-ALL 任务详情页的 **Artifacts** 区域或者仓库的 **Releases** 页面即可下载带有 `King-Sager2333` 前缀的最新固件。

---

## ⚠️ 免责声明

刷机有风险，操作需谨慎。

本项目固件仅供学习与研究使用，请确认设备型号匹配并提前备份数据。
因刷机造成的设备损坏或数据丢失，作者不承担任何责任。
