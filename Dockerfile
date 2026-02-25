# 使用官方脚本方式
FROM alpine:latest as builder
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

RUN apk add --no-cache wget tar xz \
    && wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz \
    && mkdir -p /rootfs \
    && tar -xzf /tmp/rootfs.tar.gz -C /rootfs

FROM scratch
COPY --from=builder /rootfs/ /

# 基本配置
RUN [ -d /etc/init.d ] && echo "Init system ready" || echo "No init.d found"

EXPOSE 80 443 22

CMD ["/sbin/init"]
