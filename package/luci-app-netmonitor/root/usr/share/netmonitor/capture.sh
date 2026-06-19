#!/bin/sh
# 这是一个高效且轻量的实时网络抓包解析脚本
# 主要用于解析 HTTP 请求头 (Host) 和 HTTPS 请求的 SNI (Server Name Indication)
# 提取出访问的域名，并将结果输出到标准输出供 rpcd 读取
# 作者：Jules

# 为了不让输出缓冲导致前台读取不到内容，确保可以按行输出
export unbuffer="stdbuf -o0"

# 使用 tcpdump 进行轻量级嗅探，仅捕获前向流量中的 SYN, PSH 等包的片段
# 抓取端口 80 (HTTP) 和 443 (HTTPS)
# -l: 开启行缓冲模式
# -n: 不解析主机名
# -nn: 不解析端口名
# -N: 不打印域名限定符
# -s 1500: 抓取完整的数据包，以确保能匹配到 SNI 和 Host
# -A: 打印每个数据包的 ASCII 内容（这就是我们用来匹配文本的来源）

# 将提取到的域名缓存到一个文件，供 rpcd 中的 get_connections 调用查询
DOMAIN_CACHE="/tmp/netmonitor_domain_cache"
> "$DOMAIN_CACHE"

tcpdump -l -n -nn -s 1500 -A 'tcp port 80 or tcp port 443' 2>/dev/null | awk '
BEGIN {
    # 刷新输出缓冲区，确保数据实时送达
    fflush("")
}
# 匹配数据包头部，提取源 IP 和目的 IP
/^[0-9]+:[0-9]+:[0-9]+\.[0-9]+ IP/ {
    # 提取时间
    time = $1

    # 提取源 IP (例如：192.168.1.100.12345，去掉后面的端口号)
    src = $3
    sub(/\.[0-9]+$/, "", src)

    # 提取目的 IP (例如：1.2.3.4.443)
    dst = $5
    # 去掉末尾的冒号
    sub(/:$/, "", dst)
    dst_port = dst
    # 提取端口号
    sub(/.*\./, "", dst_port)
    # 提取目的 IP
    sub(/\.[0-9]+$/, "", dst)

    current_time = time
    current_src = src
    current_dst = dst
    current_dst_port = dst_port

    # 初始化协议类型
    current_proto = ""
}

# 匹配 HTTP Host 头
/Host: / {
    if (current_dst_port == "80") {
        # 提取域名
        host = $2
        # 去掉回车换行等空白符
        gsub(/[ \r\n]+/, "", host)

        if (host != "") {
            # 打印日志格式：[时间] 主机 -> 目标URL [协议类型]
            printf "[%s] %s -> %s [HTTP]\n", current_time, current_src, host
            fflush("")

            # 保存到缓存文件 (使用 awk 的原生追加写入避免 spawn 子进程)
            print current_dst, host >> "/tmp/netmonitor_domain_cache"
            fflush("/tmp/netmonitor_domain_cache")
        }
    }
}

# HTTPS SNI 的匹配比较复杂，因为在 tcpdump -A 输出中它通常夹杂在乱码中
# 但 SNI 域名的特征通常是前面紧跟着 TLS Handshake 相关的标识，我们可以用一种简单的启发式匹配
# 即匹配出不包含特殊符号的可见字符串，且属于典型的域名格式
{
    if (current_dst_port == "443") {
        # 使用正则表达式在当前行尝试查找常见的域名特征
        # 例如：a.com, www.test.com.cn
        # 这里为了简化，我们查找前缀可能包含 SNI 扩展类型的字节，然后再跟域名
        # 在 ascii 打印中，域名通常是连续的可打印字符

        # 将整行赋给一个变量
        line = $0

        # 匹配规则：连续的小写字母、数字、点号和短横线组成的字符串，且包含点号，长度在 4 到 253 之间
        if (match(line, /[a-z0-9-]+\.[a-z0-9\.-]+/)) {
            domain = substr(line, RSTART, RLENGTH)

            # 过滤掉一些明显不是域名的误报
            if (length(domain) > 4 && domain !~ /^[0-9\.]+$/ && domain !~ /\.\./) {
                # 检查是否以常见的 TLD 结尾以增加准确性，或者我们只信任第一次出现的结果
                # 为避免同一条连接重复打印，我们可以在外部或内存中做个简单的排重
                if (!seen[current_src "-" current_dst "-" domain]) {
                    printf "[%s] %s -> %s [HTTPS]\n", current_time, current_src, domain
                    fflush("")
                    seen[current_src "-" current_dst "-" domain] = 1

                    # 保存到缓存文件 (使用 awk 的原生追加写入避免 spawn 子进程)
                    print current_dst, domain >> "/tmp/netmonitor_domain_cache"
                    fflush("/tmp/netmonitor_domain_cache")
                }
            }
        }
    }
}
'
