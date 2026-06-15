FROM debian:bookworm-slim

RUN apt update && apt install -y curl gnupg ca-certificates lsb-release && \
    curl -sSL https://packages.sury.org/php/README.txt | bash -s && \
    apt update && apt install -y php8.3 php8.3-{cli,common,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip,redis,intl} nginx composer cron unzip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/pterodactyl && cd /var/www/pterodactyl && \
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz && \
    tar -xzf panel.tar.gz && rm panel.tar.gz && \
    chmod -R 755 storage bootstrap/cache && \
    cp .env.example .env

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
