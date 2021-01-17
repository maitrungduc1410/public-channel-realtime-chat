# Set master image
FROM php:7.3-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install Additional dependencies
RUN apk update && apk add --no-cache \
    build-base shadow supervisor \
    php7 \
    php7-fpm \
    php7-common \
    php7-pdo \
    php7-pdo_mysql \
    php7-mysqli \
    php7-mcrypt \
    php7-mbstring \
    php7-xml \
    php7-openssl \
    php7-json \
    php7-phar \
    php7-zip \
    php7-gd \
    php7-dom \
    php7-session \
    php7-zlib

# Add and Enable PHP-PDO Extenstions
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable pdo_mysql

# Remove Cache
RUN rm -rf /var/cache/apk/*

# Use the default production configuration ($PHP_INI_DIR is variable already set by the default image)
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Supervisor entry configuration
COPY .docker/supervisord.conf /etc/supervisord.conf

# Start php-fpm
COPY .docker/supervisor.d/php-fpm.conf /etc/supervisor.d/php-fpm.conf

# Start Laravel worker (no need if enable Horizon)
COPY .docker/supervisor.d/worker.conf /etc/supervisor.d/worker.conf

# ==== LOCAL
# group "dialout" has ID = 20
RUN adduser -D -u 501 appuser -G dialout

RUN chown -R appuser:dialout /var/www/html

COPY --chown=appuser:dialout . /var/www/html

# ==== PRODUCTION
# RUN addgroup -g 1000 appgroup

# RUN adduser -D -u 1000 appuser -G appgroup

# RUN chown -R appuser:appgroup /var/www/html

# COPY --chown=appuser:appgroup . /var/www/html

USER appuser

CMD supervisord -n -c /etc/supervisord.conf