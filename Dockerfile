FROM debian:bullseye-slim

LABEL maintainer="Kibatic system@kibatic.com"

# https://getcomposer.org/doc/03-cli.md#composer-allow-superuser
ENV COMPOSER_ALLOW_SUPERUSER 1
ENV PERFORMANCE_OPTIM false

# Instalar dependencias generales
RUN apt-get -qq update > /dev/null && DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    apt-utils \
    supervisor \
    ca-certificates \
    nginx \
    wget \
    vim \
    git \
    curl \
    openssl \
    make \
    unzip \
    apt-transport-https \
    libpq-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalar PHP y las extensiones necesarias
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg && \
    echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/php.list && \
    apt-get update -qq > /dev/null && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq -y --no-install-recommends install \
    php8.2 \
    php8.2-cli \
    php8.2-fpm \
    php8.2-intl \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-pgsql \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalar Composer
RUN php -r "readfile('https://getcomposer.org/installer');" | php -- \
    --install-dir=/usr/local/bin \
    --filename=composer

# Configuración de Nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf && \
    mkdir -p /run/php

# Copiar archivos de configuración
COPY rootfs /

WORKDIR /var/www

# Instalar dependencias PHP necesarias con Composer
RUN composer require cloudinary/cloudinary_php supabase/supabase-php guzzlehttp/guzzle:7.5 doctrine/dbal

EXPOSE 80

CMD ["/entrypoint.sh"]

