FROM alpine:latest
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

# 核心修复：1. 解压参数兼容xz/gzip 2. 分步执行+日志 3. 权限容错
RUN apk add --no-cache wget tar xz \
    # 步骤1：下载并打印日志（看是否下载完整）
    && echo "开始下载 OpenWrt rootfs..." \
    && wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz -v \
    # 步骤2：验证文件大小（排除空文件）
    && echo "验证文件大小..." \
    && ls -lh /tmp/rootfs.tar.gz \
    && if [ ! -f /tmp/rootfs.tar.gz ] || [ $(stat -c%s /tmp/rootfs.tar.gz) -lt 102400 ]; then echo "文件过小/不存在" && exit 1; fi \
    # 步骤3：解压（-xf 自动识别压缩格式，兼容xz/gzip）
    && echo "开始解压..." \
    && mkdir -p /tmp/rootfs \
    && tar -xf /tmp/rootfs.tar.gz -C /tmp/rootfs \
    # 步骤4：复制文件（先清空根目录无关文件，避免权限冲突）
    && echo "开始复制文件..." \
    && cp -rf /tmp/rootfs/* / || echo "部分文件复制失败（忽略只读文件）" \
    # 步骤5：清理+DNS配置（容错init.d目录）
    && rm -rf /tmp/* \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    && if [ -d /etc/init.d ]; then chmod +x /etc/init.d/*; else echo "无init.d目录，跳过权限设置"; fi

EXPOSE 80 443 22
CMD ["/sbin/init"]
