#!/bin/bash
set -e

cd /var/www/pterodactyl

# Configure .env from Railway env vars
sed -i "s/DB_HOST=.*/DB_HOST=$MYSQLHOST/" .env
sed -i "s/DB_PORT=.*/DB_PORT=$MYSQLPORT/" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=$MYSQLDATABASE/" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=$MYSQLUSER/" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$MYSQLPASSWORD/" .env

# Generate key if not set
php artisan key:generate --force 2>/dev/null || true

# Run migrations
php artisan migrate --seed --force 2>/dev/null || true

# Start services
php-fpm8.3 -R
nginx

# Start queue worker in background
php artisan queue:work --queue=high,standard,low --sleep=3 --tries=3 &
echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1" | crontab -

# Keep container alive
tail -f /dev/null
