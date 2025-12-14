FROM alpine:3.18

# Install dependencies including OpenRC and NFS client tools
RUN apk add --no-cache \
    bash curl iptables ip6tables containerd runc openrc \
    nfs-utils \
    && rm -rf /var/cache/apk/*

# Install k3s with SKIP_SYSTEMD_OR_OPENRC_CHECK
RUN curl -sfL https://get.k3s.io -o /tmp/install.sh && \
    INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_ENABLE=true sh /tmp/install.sh && \
    rm /tmp/install.sh

# Configure system
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && \
    echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10250

ENTRYPOINT ["/entrypoint.sh"]