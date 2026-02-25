FROM scratch
ARG OPENWRT_VERSION=23.05.3

# 使用官方提供的 rootfs 下载地址
ADD https://downloads.openwrt.org/releases/${OPENWRT_VERSION}/targets/x86/64/openwrt-${OPENWRT_VERSION}-x86-64-rootfs.tar.gz /

# 解压并清理
RUN tar -xzf /*-rootfs.tar.gz -C / --strip-components=1 \
    && rm -f /*-rootfs.tar.gz \
    && mkdir -p /var/lock /var/run

EXPOSE 80 443 22

ENTRYPOINT ["/sbin/init"]
