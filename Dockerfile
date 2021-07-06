FROM php:7.4-alpine3.13

RUN mkdir -p /run/nginx && mkdir -p /run/php && \
    apk add --update bash nginx jq unzip vim zip \
    jpeg-dev libpng-dev libpq libwebp-dev libzip-dev && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ --allow-untrusted gnu-libiconv && \
    rm -rf /var/cache/apk/* && \
    docker-php-ext-configure zip --with-zip && \
    docker-php-ext-configure gd --with-jpeg --with-webp && \
    docker-php-ext-install exif gd mysqli opcache pdo_mysql zip && \
    { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/docker-oc-opcache.ini && \
    { \
    echo 'log_errors=on'; \
    echo 'display_errors=off'; \
    echo 'upload_max_filesize=32M'; \
    echo 'post_max_size=32M'; \
    echo 'memory_limit=128M'; \
    } > /usr/local/etc/php/conf.d/docker-oc-php.ini

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php

# Get Composer
RUN curl -sS https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer && \
    /usr/local/bin/composer config -g repo.packagist composer https://packagist.org && \
    /usr/local/bin/composer global require hirak/prestissimo
