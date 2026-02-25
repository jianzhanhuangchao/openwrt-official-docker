# 基于极简 alpine 构建纯官方 OpenWrt
FROM alpine:latest

# 定义参数（方便切换 OpenWrt 版本/架构）
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

# 修复点1：预装依赖 + 换国内清华源下载（解决超时/404）
RUN apk add --no-cache wget tar \
    && wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz \
    # 验证文件是否下载成功（增加容错）
    && if [ ! -f /tmp/rootfs.tar.gz ]; then echo "下载失败" && exit 1; fi \
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
