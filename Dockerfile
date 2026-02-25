# 基于极简 alpine 构建纯官方 OpenWrt
FROM alpine:latest

# 定义参数（方便切换 OpenWrt 版本/架构）
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

# 下载官方 rootfs（从 OpenWrt 官网拉取，确保纯官方）
RUN wget https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz \
    && mkdir -p /tmp/rootfs \
    && tar -xzf /tmp/rootfs.tar.gz -C /tmp/rootfs \
    && cp -rf /tmp/rootfs/* / \
    && rm -rf /tmp/* \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    && chmod +x /etc/init.d/*

# 暴露端口
EXPOSE 80 443 22

# 启动 init 进程
CMD ["/sbin/init"]