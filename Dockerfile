# 第一阶段：下载和解压
FROM alpine:latest as builder
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

RUN apk add --no-cache wget tar xz \
    && echo "下载OpenWrt rootfs..." \
    && wget https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz \
    && mkdir -p /rootfs \
    && tar -xzf /tmp/rootfs.tar.gz -C /rootfs \
    && rm -f /tmp/rootfs.tar.gz \
    && echo "下载和解压完成"

# 第二阶段：构建最终镜像
FROM scratch
COPY --from=builder /rootfs/ /

# 创建必要的系统目录和设备文件
RUN mkdir -p /var/lock /var/run /var/log /var/state /var/empty /dev/pts /proc /sys /tmp /overlay \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    && echo "nameserver 114.114.114.114" >> /etc/resolv.conf \
    # 创建设备文件（忽略错误）
    && mknod -m 666 /dev/null c 1 3 2>/dev/null || true \
    && mknod -m 644 /dev/random c 1 8 2>/dev/null || true \
    && mknod -m 644 /dev/urandom c 1 9 2>/dev/null || true \
    && mknod -m 666 /dev/zero c 1 5 2>/dev/null || true \
    && mknod -m 666 /dev/console c 5 1 2>/dev/null || true \
    # 创建标准输入输出软链接
    && ln -sf /proc/self/fd /dev/fd 2>/dev/null || true \
    && ln -sf /proc/self/fd/0 /dev/stdin 2>/dev/null || true \
    && ln -sf /proc/self/fd/1 /dev/stdout 2>/dev/null || true \
    && ln -sf /proc/self/fd/2 /dev/stderr 2>/dev/null || true \
    # 设置root密码为空（可选）
    && sed -i 's/root:x:0:0:root:\/root:\/bin\/ash/root::0:0:root:\/root:\/bin\/ash/' /etc/passwd 2>/dev/null || true \
    # 验证init.d目录
    && if [ -d /etc/init.d ]; then \
         echo "Init system ready with $(ls /etc/init.d/ | wc -l) services"; \
         chmod +x /etc/init.d/* 2>/dev/null || true; \
       else \
         echo "Warning: /etc/init.d not found"; \
       fi

EXPOSE 22 80 443 53/udp 67/udp 161/udp

# 使用OpenWrt的procd作为初始化系统
CMD ["/sbin/init"]
