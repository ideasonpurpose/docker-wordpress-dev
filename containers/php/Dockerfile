FROM php:7.2-fpm

RUN apt-get update && apt-get install -y  --no-install-recommends \
      # libcurl3-dev \
      # libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

&& docker-php-ext-install curl \
&& docker-php-ext-install fileinfo \
&& docker-php-ext-install gd \
&& docker-php-ext-install iconv \
&& docker-php-ext-install imagick \
&& docker-php-ext-install intl \
&& docker-php-ext-install json \
&& docker-php-ext-install mbstring \
&& docker-php-ext-install mysqli \
&& docker-php-ext-install phar \
&& docker-php-ext-install xml \
&& docker-php-ext-install xmlrpc \
&& docker-php-ext-install zip \


RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
    && docker-php-ext-install iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install  gd



# Possible values for ext-name:
#   bcmath
#   bz2
#   calendar
#   ctype
#   curl
#   dba
#   dom
#   enchant
#   exif
#   fileinfo
#   filter
#   ftp
#   gd
#   gettext
#   gmp
#   hash
#   iconv
#   imap
#   interbase
#   intl
#   json
#   ldap
#   mbstring
#   mysqli
#   oci8
#   odbc
#   opcache
#   pcntl
#   pdo
#   pdo_dblib
#   pdo_firebird
#   pdo_mysql
#   pdo_oci
#   pdo_odbc
#   pdo_pgsql
#   pdo_sqlite
#   pgsql
#   phar
#   posix
#   pspell
#   readline
#   recode
#   reflection
#   session
#   shmop
#   simplexml
#   snmp
#   soap
#   sockets
#   sodium
#   spl
#   standard
#   sysvmsg
#   sysvsem
#   sysvshm
#   tidy
#   tokenizer
#   wddx
#   xml
#   xmlreader
#   xmlrpc
#   xmlwriter
#   xsl
#   zend_test
#   zip


# RUN docker-php-ext-install mysqli

# RUN docker-php-ext-install mysqli pdo pdo_mysql

# CMD ['php-fpm']

# WIPING AGAIN

# ENV PACKAGES="gettext-dev curl-dev freetype-dev libmcrypt-dev imagemagick-dev libxml2-dev libpng-dev libjpeg-turbo-dev" \
#     DEV_PACKAGES="autoconf coreutils libltdl libtool g++ make pcre-dev bzip2-dev" \
#     EXTENTIONS="bz2 curl exif gettext iconv mbstring mysqli pdo pdo_mysql mcrypt gd xmlrpc zip"


# RUN apk add --update --no-cache $DEV_PACKAGES \
#   && apk add --no-cache $PACKAGES \
#   && pecl install imagick && docker-php-ext-enable imagick \
#   && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
#   && docker-php-ext-install $EXTENTIONS \
#   && apk del $DEV_PACKAGES




# #  PAUSING TO TRY SOMETHING DIFFERENT

# # # RUN apk add --update --no-cache libcurl curl-dev
# # RUN apk add --update --no-cache \
# #   gettext-dev \
# #   libmcrypt-dev \
# #   libxml2-dev \
# #   libpng-dev \
# #   libjpeg-turbo-dev \

# #   && docker-php-ext-install \
# # # RUN apt-get update && \
# # #     apt-get install -y libcurl --no-install-recommends && \
# # #     rm -rf /var/lib/apt/lists/*
# # # RUN docker-php-ext-install cli
# # # RUN docker-php-ext-install common
# # # RUN docker-php-ext-install \
# #   # curl \
# #   gd \
# # # RUN docker-php-ext-install imagick
# #   gettext \
# #   mcrypt \
# #   # mysql \
# #   mysqli \
# #   # xml \
# #   xmlrpc

# # # RUN docker-php-ext-enable \
# # #   gd \
# # # # RUN docker-php-ext-install imagick
# # #   mcrypt \
# # #   # mysql \
# # #   mysqli \
# # #   # xml \
# # #   xmlrpc

# # # COPY . /var/www/html
# # # WORKDIR /var/www/html
# # # CMD ['php', './index.php']
# # CMD
