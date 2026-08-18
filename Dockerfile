FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash \
    ca-certificates \
    socat \
    tzdata \
    sqlite3 \
    nginx \
    gettext-base \
    tar \
    gzip \
    file \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p \
    /etc/x-ui \
    /var/log/x-ui \
    /usr/local/x-ui \
    /usr/share/nginx/html/view

# Download the latest amd64 release directly.
# Do not use /releases/latest API endpoint.
RUN set -eux; \
    curl -fL \
    "https://github.com/MHSanaei/3x-ui/releases/download/v3.6.0/x-ui-linux-amd64.tar.gz" \
    -o /tmp/x-ui-linux-amd64.tar.gz; \
    file /tmp/x-ui-linux-amd64.tar.gz; \
    tar -xzf /tmp/x-ui-linux-amd64.tar.gz -C /usr/local/; \
    rm -f /tmp/x-ui-linux-amd64.tar.gz; \
    test -f /usr/local/x-ui/x-ui; \
    chmod +x /usr/local/x-ui/x-ui

COPY nginx.conf.template /etc/nginx/nginx.conf.template

COPY start.sh /start.sh
RUN chmod +x /start.sh

COPY sub-view.html /usr/share/nginx/html/view/index.html

EXPOSE 80

CMD ["/start.sh"]
