FROM registry.docker.ir/php:8.3.7-cli

WORKDIR /var/www/html

# Install common php extension dependencies
RUN apt-get update && apt-get install -y \
    libfreetype-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    zlib1g-dev \
    libzip-dev \
    unzip \
    supervisor \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install bcmath \
    && docker-php-ext-install zip pdo pdo_mysql opcache \
    && pecl install -o -f redis \
    && docker-php-ext-enable redis

RUN docker-php-ext-configure pcntl --enable-pcntl \
    && docker-php-ext-install \
    pcntl

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/bin --filename=composer

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY ./docker_config/php/opcache.ini $PHP_INI_DIR/conf.d

ADD .docker_config/supervisor.conf /etc/

CMD ["supervisord", "-c", "/etc/supervisord.conf"]