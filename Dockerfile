FROM php:7.0-fpm

ENV PHP_EXTRA_CONFIGURE_ARGS --enable-fpm --with-fpm-user=www-data --with-fpm-group=www-data --enable-intl --enable-opcache --enable-zip
ENV COMPOSER_MAGENTO_VERSION=2.2.2
ENV magrepouser=2b1db2836a1bdc0b3740257716f942bb
ENV magrepopw=ae59850def572919979465cc57250480
RUN apt-get update

RUN \
  apt-get install -y \
  libcurl4-gnutls-dev \
  libxml2-dev \
  libssl-dev

RUN \
    /usr/local/bin/docker-php-ext-install \
    dom \
    pcntl \
    phar \
    posix


# Configure PHP
# php module build deps
RUN \
  apt-get install -y \
  g++ \
  autoconf \
  libbz2-dev \
  libltdl-dev \
  libpng12-dev \
  libjpeg62-turbo-dev \
  libfreetype6-dev \
  libxpm-dev \
  libimlib2-dev \
  libicu-dev \
  libmcrypt-dev \
  libxslt1-dev \

  re2c \
  libpng++-dev \
  libpng3 \
  libvpx-dev \
  zlib1g-dev \
  libgd-dev \
  libtidy-dev \
  libmagic-dev \
  libexif-dev \
  file \
  libssh2-1-dev \
  libjpeg-dev \
  git \
  curl \
  wget \
  librabbitmq-dev \
  libzip-dev \
  libzip2

# http://devdocs.magento.com/guides/v2.2/install-gde/system-requirements.html
RUN \
    /usr/local/bin/docker-php-ext-install \
    pdo \
    sockets \
    pdo_mysql \
    mysqli \
    mbstring \
    mcrypt \
    hash \
    simplexml \
    xsl \
    soap \
    intl \
    bcmath \
    json \
    opcache \
    zip


# Make sure the volume mount point is empty
RUN rm -rf /var/www/html/*

# Set www-data as owner for /var/www
RUN chown -R www-data:www-data /var/www/
RUN chmod -R g+w /var/www/

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Magento auth for main repo
#RUN mkdir ~/.composer \
#> ~/.composer/auth.json
RUN "cat > ~/.composer/auth.json <<EOF 
{
	"http-basic": {
		"repo.magento.com": {
			"username":"$magrepouser",
			"password":"$magrepopw"
		}
	}
}
EOF"

RUN composer create-project \
--ignore-platform-reqs \
--repository-url=https://repo.magento.com/ \
magento/project-community-edition \
/var/www/html $COMPOSER_MAGENTO_VERSION

VOLUME /var/www/html

# Create log folders
RUN mkdir /var/log/php-fpm && \
    touch /var/log/php-fpm/access.log && \
    touch /var/log/php-fpm/error.log && \
    chown -R www-data:www-data /var/log/php-fpm
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr \
    && docker-php-ext-install gd
