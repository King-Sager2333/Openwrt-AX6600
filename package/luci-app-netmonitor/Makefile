# 这是一个为 OpenWrt 编译包编写的 Makefile
# 包含包的基本信息和依赖项，以及安装步骤

include $(TOPDIR)/rules.mk

# 包的名称
LUCI_TITLE:=LuCI support for Deep Network Connection Monitor
# 包的依赖：依赖 conntrack-tools 进行连接断开，依赖 tcpdump 进行网络抓包
LUCI_DEPENDS:=+conntrack-tools +tcpdump

# 引入 LuCI 的默认包构建规则
include $(TOPDIR)/feeds/luci/luci.mk

# 调用编译系统，如果没有此行，将不会编译出 ipk 包
# call BuildPackage - OpenWrt buildroot signature
