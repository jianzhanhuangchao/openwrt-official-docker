FROM scratch
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

# 添加元数据
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="Official OpenWrt ${OPENWRT_VERSION} ${OPENWRT_ARCH} Docker image"
LABEL version="${OPENWRT_VERSION}"

# 下载并导入 OpenWrt rootfs
ADD https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz /rootfs.tar.gz

# 从 rootfs 构建镜像
RUN tar -xzf /rootfs.tar.gz -C / \
    && rm -f /rootfs.tar.gz \
    # 创建必要的目录和文件
    && mkdir -p /var/lock \
    && mkdir -p /var/run \
    && mkdir -p /etc/dropbear \
    # 设置 DNS
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    # 设置 root 密码为空（可选）
    && sed -i 's/root:x:0:0:root:\/root:\/bin\/ash/root::0:0:root:\/root:\/bin\/ash/' /etc/passwd

EXPOSE 80 443 22 53/udp 67/udp

# 使用 OpenWrt 的 procd 作为初始化系统
ENTRYPOINT ["/sbin/init"]
