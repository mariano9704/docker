FROM php:8.3.7-fpm

WORKDIR /var/www/html

# Install common php extension dependencies
RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip pdo pdo_mysql \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin --filename=composer

RUN groupadd --gid 0 appuser \
    && useradd --uid 0 -g appuser \
    -G www-data,root --shell /bin/bash \
    --create-home appuser

USER appuser