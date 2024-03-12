# Set master image
FROM php:8.3-fpm-alpine

LABEL maintainer="Mai Trung Duc (maitrungduc1410@gmail.com)"

# Set working directory
WORKDIR /app

# Install Additional dependencies
RUN apk update && apk add --no-cache supervisor

# Add and Enable PHP-PDO Extenstions
RUN docker-php-ext-install pdo pdo_mysql
RUN docker-php-ext-enable pdo_mysql
RUN docker-php-ext-install pcntl

# Remove Cache
RUN rm -rf /var/cache/apk/*

# Use the default production configuration ($PHP_INI_DIR is variable already set by the default image)
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

#-----------SUPERVISOR------------
COPY .docker/supervisord.conf /etc/supervisord.conf

# Laravel horizon
# Note that Horizon already includes worker
# Otherwise we need to run queue:work manually to spawn workers
COPY .docker/supervisor.d /etc/supervisor.d

# Copy existing application directory permissions
COPY . .

RUN addgroup -g 1000 myusergroup
RUN adduser -D -u 1000 myuser -G myusergroup

RUN chown -R myuser:myusergroup .

USER myuser

CMD supervisord -n -c /etc/supervisord.conf
