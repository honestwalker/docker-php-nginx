# PHP-FPM 7.0.11 + NGINX 1.10.2

## Usage

Pull the image, create a new container and start it:

```
docker pull jmaple/docker-php-nginx:debuggable
docker create --name php -p 80:80 --env XDEBUG_CONFIG="idekey=PHPSTORM profiler_enable=1" --restart=always jmaple/docker-php-nginx:debuggable
docker start php
```

## Extensions

* git
* swoole
* iconv
* mcrypt
* gd
* pdo
* pdo_mysql
* xml
* zip
* freetds
* pdo_dblib
* ffmpeg
* GraphicsMagick 1.3.24
* gmagick 2.0.4RC1
* icu
* php intl
* xdebug
