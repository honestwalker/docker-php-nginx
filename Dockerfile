FROM php:7.0.11-fpm

# install nginx
ENV NGINX_VERSION 1.10.2-1~jessie
# Stable packages
ENV NGINX_PACKAGES http://nginx.org/packages/debian/
# Mainline packages
#ENV NGINX_PACKAGES http://nginx.org/packages/mainline/debian/
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb ${NGINX_PACKAGES} jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
	&& rm -rf /var/lib/apt/lists/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libjpeg62-turbo-dev
RUN apt-get install -y libmcrypt-dev
RUN apt-get install -y libpng12-dev


# swoole
ENV SWOOLE_VERSION 1.8.13-stable
RUN curl -L -O https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz \
                && tar zxvf v${SWOOLE_VERSION}.tar.gz \
                && cd swoole-src-${SWOOLE_VERSION} \
                && phpize \
                && ./configure \
                && make \
                && make install \
                && cd .. \
                && rm -rf swoole-src-${SWOOLE_VERSION}
RUN docker-php-ext-enable swoole


# install php extensions
RUN docker-php-ext-install -j$(nproc) iconv mcrypt

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install -j$(nproc) gd

RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql


# pdo_dblib
RUN apt-get install -y freetds-dev
RUN docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu
RUN docker-php-ext-install pdo_dblib
RUN sed -i "s|\[global\]|\[global\]\ntds version = 8.0\nclient charset = UTF-8|g" /etc/freetds/freetds.conf


# ffmpeg
RUN echo 'deb http://www.deb-multimedia.org jessie main non-free\n\
deb-src http://www.deb-multimedia.org jessie main non-free\n' >> /etc/apt/sources.list
RUN apt-get update \
    && apt-get install -y --force-yes deb-multimedia-keyring \
    && apt-get update \
    && apt-get install -y ffmpeg


# GraphicsMagick
ENV GRAPHICS_MAGICK_VERSION 1.3.24
RUN curl -L -O https://downloads.sourceforge.net/graphicsmagick/graphicsmagick/${GRAPHICS_MAGICK_VERSION}/GraphicsMagick-${GRAPHICS_MAGICK_VERSION}.tar.gz \
  && tar -zxvf GraphicsMagick-${GRAPHICS_MAGICK_VERSION}.tar.gz \
  && cd GraphicsMagick-${GRAPHICS_MAGICK_VERSION} \
  && ./configure --enable-shared \
  && make \
  && make install

# gmagick
RUN pecl install gmagick-2.0.4RC1
RUN docker-php-ext-enable gmagick


# SOAP
RUN apt-get install -y libxml2-dev \
		&& docker-php-ext-install soap


# icu & php intl
RUN apt-get install -y libicu52 libicu-dev \
		&& docker-php-ext-install intl

# xdebug
RUN pecl install xdebug \
    && rm -rf /tmp/pear
COPY conf.d/* /usr/local/etc/php/conf.d/


EXPOSE 80 443 9000
CMD nginx && php-fpm
