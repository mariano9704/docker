FROM registry.docker.ir/php:8.3.7-fpm

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
    && docker-php-ext-install zip pdo pdo_mysql opcache \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis

RUN docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install \
    pcntl

RUN curl -sS https://getcomposer.org/installer | \
php -- --install-dir=/usr/bin --filename=composer

#Installing node 12.x
RUN curl -sL https://deb.nodesource.com/setup_20.x| bash -
RUN apt-get install -y nodejs

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY ./docker_config/php/opcache.ini $PHP_INI_DIR/conf.d

EXPOSE 9000
CMD ["php-fpm"]