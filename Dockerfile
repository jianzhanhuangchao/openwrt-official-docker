# 第一阶段：下载和解压
FROM alpine:latest as builder
ARG OPENWRT_VERSION=23.05.3
ARG OPENWRT_ARCH=x86_64

RUN apk add --no-cache wget tar xz \
    && echo "开始下载 OpenWrt rootfs..." \
    && wget https://mirrors.tuna.tsinghua.edu.cn/openwrt/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz -O /tmp/rootfs.tar.gz -v \
    && echo "验证文件大小..." \
    && ls -lh /tmp/rootfs.tar.gz \
    && if [ ! -f /tmp/rootfs.tar.gz ] || [ $(stat -c%s /tmp/rootfs.tar.gz) -lt 102400 ]; then echo "文件过小/不存在" && exit 1; fi \
    && mkdir -p /output \
    && tar -xf /tmp/rootfs.tar.gz -C /output \
    && rm -f /tmp/rootfs.tar.gz

# 第二阶段：构建最终镜像
FROM scratch
COPY --from=builder /output/ /

# 配置系统
RUN mkdir -p /var/lock /var/run /etc/dropback \
    && echo "nameserver 8.8.8.8" > /etc/resolv.conf \
    && echo "root::0:0:root:/root:/bin/ash" > /etc/passwd \
    && echo "root:x:0:" > /etc/group

EXPOSE 80 443 22 53/udp 67/udp

ENTRYPOINT ["/sbin/init"]
