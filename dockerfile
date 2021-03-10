FROM php:7.4.16-fpm-alpine  
# Ajout d'un commentaire pour GIT

WORKDIR /application
# Mise a jour du conteneur Alpine
RUN apk update && apk upgrade
# Installation des librairies utiles dans le conteneur 
RUN apk add --update --no-cache libgd libpng-dev imagemagick-dev libjpeg-turbo-dev freetype-dev curl wget vim bash
# Installation de l'extention PHP bzip2
RUN apk add --no-cache bzip2-dev \
    && docker-php-ext-install -j$(nproc) bz2 && docker-php-ext-enable bz2 \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention PHP GD
RUN apk add --no-cache freetype libjpeg-turbo libpng freetype-dev libjpeg-turbo-dev libpng-dev \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
      # --with-png=/usr/include/ \ # No longer necessary as of 7.4; https://github.com/docker-library/php/pull/910#issuecomment-559383597
    && docker-php-ext-install -j$(nproc) gd && docker-php-ext-enable gd && apk del --no-cache freetype-dev libjpeg-turbo-dev libpng-dev \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention PHP  intl
RUN apk add --no-cache icu-dev \
    && docker-php-ext-install -j$(nproc) intl && docker-php-ext-enable intl \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention PHP mbstring
RUN apk add --no-cache oniguruma-dev \
    && docker-php-ext-install mbstring && docker-php-ext-enable mbstring \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention PHP opcache redis
RUN docker-php-source extract \
    && apk --update --no-cache add autoconf g++ make \
    && pecl install opcache redis apcu && docker-php-ext-enable opcache redis apcu && docker-php-source delete \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention mysql
RUN docker-php-ext-install mysqli pdo pdo_mysql \
    && docker-php-ext-enable pdo_mysql \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention zip
RUN apk add --no-cache zip libzip-dev && docker-php-ext-configure zip && docker-php-ext-install zip \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention exif
RUN docker-php-ext-install exif && docker-php-ext-enable exif \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention imagik
RUN apk add imagemagick imagemagick-libs
RUN pecl install imagick && docker-php-ext-enable imagick \
    && rm -rf /tmp/* /var/cache/apk/*
# Installation de l'extention gmagick
#RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community php7 graphicsmagick
#RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing php7-gmagick
# Installation de l'applis PHP
RUN set -eux; \
	version='1.7.2'; \
	curl -o humhub.tar.gz -fL "https://www.humhub.com/download/package/humhub-$version.tar.gz"; \
	tar -xzf humhub.tar.gz -C /usr/src/; \
	mv /usr/src/humhub-$version /usr/src/humhub; \
	rm humhub.tar.gz
WORKDIR /var/www/html
COPY docker-entrypoint.sh /entrypoint.sh
VOLUME /var/www/html
COPY crontab /etc/crontabs/root
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
