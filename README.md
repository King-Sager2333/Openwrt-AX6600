# 🚀 OpenWrt AX6600 / IPQ60xx Router Firmware (Cloud Build + NSS Acceleration)

OpenWrt / AX6600 / IPQ6010 / JDCloud RE-CS-02 / NSS / Router Firmware / Cloud Build
> 基于 OpenWrt / ImmortalWrt 的定制固件，适配 JDCloud RE-CS-02（京东云雅典娜 AX6600），集成 NSS 硬件加速优化与 GitHub Actions 自动云编译

**当前版本前缀：`King-Sager2333`**

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
| **Argon Theme** (`luci-theme-argon`) | `luci-i18n-argon-config-zh-cn` | 美观且功能丰富的现代化 LuCI 界面主题，附带可视化的主题设置模块。 |
| **HomeProxy** (`luci-app-homeproxy`) | `luci-i18n-homeproxy-zh-cn` | 新一代代理工具，提供极简的配置页面和极致的性能。 |
