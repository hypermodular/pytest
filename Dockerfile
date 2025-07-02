# Use Alpine Linux as the base image
FROM alpine:3.18

# Install CoreDNS, docker-gen, and required tools
RUN apk add --no-cache \
    coredns \
    curl \
    bash \
    tzdata \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Install docker-gen
RUN curl -L https://github.com/jwilder/docker-gen/releases/download/0.11.0/docker-gen-alpine-linux-amd64-0.11.0.tar.gz | tar -xz -C /usr/local/bin docker-gen

# Create necessary directories
RUN mkdir -p /etc/docker-gen/templates /etc/coredns

# Copy configuration files
COPY coredns/Corefile /etc/coredns/Corefile
COPY coredns/Corefile.tmpl /etc/docker-gen/templates/Corefile.tmpl

# Create hosts file
RUN echo "127.0.0.1 localhost" > /etc/coredns/hosts

# Create entrypoint script
RUN echo '#!/bin/sh\n\n# Start docker-gen in the background\ndocker-gen -watch -only-published \\\n    /etc/docker-gen/templates/Corefile.tmpl \\\n    /etc/coredns/hosts &\n\n# Start CoreDNS in the foreground\nexec coredns -conf /etc/coredns/Corefile' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Expose DNS ports
# 9153 is used for metrics
EXPOSE 53/udp 53/tcp 9153/tcp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --spider http://localhost:8080/health || exit 1
