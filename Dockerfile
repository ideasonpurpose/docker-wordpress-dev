FROM wordpress:latest

# Overload the environment in the default image (instead of docker-compose)
# ENV WORDPRESS_DEBUG 1

RUN echo "[File Uploads]" > /usr/local/etc/php/conf.d/z_iop_max_file_size.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/z_iop_max_file_size.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/z_iop_max_file_size.ini

RUN echo "[Execution Time]" > /usr/local/etc/php/conf.d/z_iop_max_execution_time.ini \
    && echo "max_execution_time = 600" >> /usr/local/etc/php/conf.d/z_iop_max_execution_time.ini

RUN echo "[Resource Limits]" > /usr/local/etc/php/conf.d/z_iop_resource_limits.ini \
    && echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/z_iop_resource_limits.ini

RUN echo "[Error Reporting]" > /usr/local/etc/php/conf.d/z_iop-debug.ini \
    && echo "display_errors = on" >> /usr/local/etc/php/conf.d/z_iop-debug.ini \
    && echo "display_startup_errors = on" >> /usr/local/etc/php/conf.d/z_iop-debug.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/z_iop-debug.ini

RUN echo "[OPcache]" > /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.memory_consumption=192" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.max_wasted_percentage=10" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini

# Install XDebug, largly copied from:
# https://github.com/andreccosta/wordpress-xdebug-dockerbuild
RUN pecl install "xdebug" \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.profiler_enable_trigger = 1" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo "xdebug.profiler_output_dir = /tmp/xdebug_profiler" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && rm -rf /tmp/pear
    # && echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini
    # && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # && echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # && echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /usr/local/etc/php/conf.d/xdebug.ini

# Make sure the profiler directory exists and is writable by www-data
RUN mkdir /tmp/xdebug_profiler \
    && chown www-data:www-data /tmp/xdebug_profiler

# Install the PHP Imagick extension, solution found here:
# https://github.com/docker-library/php/issues/105#issuecomment-421081065
# RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
#     && apt-get update \
#     && apt-get install -y --no-install-recommends \
#       libmagickwand-dev \
#       mysql-client \
#       # vim \
#     && rm -rf /var/lib/apt/lists/* \
#     && pecl install imagick-3.4.3 \
#     && docker-php-ext-enable imagick

# TODO: Is imageMagick installed? Got this mesage:
#    > Installing '/usr/local/include/php/ext/imagick/php_imagick_shared.h'
#    > Installing '/usr/local/lib/php/extensions/no-debug-non-zts-20170718/imagick.so'
#    > install ok: channel:#pecl.php.net/imagick-3.4.3
#    > configuration option "php_ini" is not set to php.ini location
#    > You should add "extension=imagick.so" to php.ini

# TODO: This looks easier?
# https://ourcodeworld.com/articles/read/645/how-to-install-imagick-for-php-7-in-ubuntu-16-04


# Install jq for merging package.json files
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
      jq \
    && rm -rf /var/lib/apt/lists/*

COPY package.json /usr/src/
COPY default.config.js /usr/src/
COPY boilerplate-theme/ /usr/src/boilerplate-theme
COPY boilerplate-tooling/ /usr/src/boilerplate-tooling

COPY *.sh /usr/local/bin/
# COPY update-package-json-scripts.php /usr/local/bin/

ENTRYPOINT ["docker-entrypoint-iop.sh"]

CMD ["apache2-foreground"]
