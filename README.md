# PHP-FPM 7.0.11 + NGINX 1.10.2

## Usage

Pull the image, create a new container and start it:

```
docker pull jmaple/docker-php-nginx
docker create --name php -p 80:80 --restart=always jmaple/docker-php-nginx
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
* freetds
* pdo_dblib
* ffmpeg
* GraphicsMagick 1.3.24
* gmagick 2.0.4RC1
* icu
* php intl
