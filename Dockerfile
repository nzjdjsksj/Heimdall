FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tehran

# نصب وابستگی‌ها
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
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
    && rm -rf /var/lib/apt/lists/*

# ساخت مسیرهای مورد نیاز
RUN mkdir -p \
    /etc/x-ui \
    /var/log/x-ui \
    /usr/local/x-ui \
    /usr/share/nginx/html/view

# دانلود آخرین نسخه Heimdall
RUN set -eux; \
    curl -fsSL \
    https://api.github.com/repos/sh7CBAC/Heimdall/releases/latest \
    -o /tmp/release.json; \
    DOWNLOAD_URL="$(grep -o 'https://[^"]*x-ui-linux-amd64[^"]*\.tar\.gz' /tmp/release.json | head -n 1)"; \
    if [ -z "$DOWNLOAD_URL" ]; then \
        echo "ERROR: Could not find amd64 Heimdall release asset"; \
        cat /tmp/release.json; \
        exit 1; \
    fi; \
    echo "Downloading: $DOWNLOAD_URL"; \
    curl -fL "$DOWNLOAD_URL" -o /tmp/x-ui.tar.gz; \
    file /tmp/x-ui.tar.gz || true; \
    tar -xzf /tmp/x-ui.tar.gz -C /usr/local/; \
    rm -f /tmp/x-ui.tar.gz /tmp/release.json; \
    test -f /usr/local/x-ui/x-ui; \
    chmod +x /usr/local/x-ui/x-ui

# فایل تنظیمات Nginx
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# اسکریپت اجرا
COPY start.sh /start.sh
RUN chmod +x /start.sh

# صفحه Subscription/View
COPY sub-view.html /usr/share/nginx/html/view/index.html

# پورت Railway
EXPOSE 3000

CMD ["/start.sh"]
