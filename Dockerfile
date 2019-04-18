FROM wordpress:latest

# Overload the environment in the default image (instead of docker-compose)
ENV WORDPRESS_DEBUG 1
# RUN touch /var/www/php-debug.conf \
RUN echo \
    && echo "display_errors = on" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "display_startup_errors =  on" >> /usr/local/etc/php/conf.d/debug.ini \
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/debug.ini

# Install XDebug, largly copied from:
# https://github.com/andreccosta/wordpress-xdebug-dockerbuild
ENV XDEBUG_PORT 9000
ENV XDEBUG_IDEKEY docker
RUN pecl install "xdebug" \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /usr/local/etc/php/conf.d/xdebug.ini

# TODO: remove this, move into https://github.com/ideasonpurpose/wp-theme-init
# # Install the Kint debugger
# RUN mkdir -p /var/www/lib/kint \
#     && curl -L https://raw.githubusercontent.com/kint-php/kint/master/build/kint.phar > /var/www/lib/kint/kint.phar

# Install the PHP Imagick extension, solution found here:
# https://github.com/docker-library/php/issues/105#issuecomment-421081065
RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && apt-get update \
    && apt-get install -y --no-install-recommends libmagickwand-dev mysql-client \
    && apt-get install vim -y \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick

# TODO: This looks easier?
# https://ourcodeworld.com/articles/read/645/how-to-install-imagick-for-php-7-in-ubuntu-16-04


# TODO: Is TideWays XHProf worth bothering with? Other options?
# run apt-get install -qq php-tideways graphviz \
#     && mkdir -p /var/www/lib/xhprof \
#     && echo 'extension=tideways.so' >> /usr/local/etc/php/conf.d/tideways.ini \
#     && echo 'tideways.framework=wordpress' >> /usr/local/etc/php/conf.d/tideways.ini \
#     && echo 'tideways.auto_prepend_library=0' >> /usr/local/etc/php/conf.d/tideways.ini \
#     && echo 'xhprof.output_dir="/tmp/xhprof"' >> /usr/local/etc/php/conf.d/tideways.ini


COPY docker-entrypoint-iop.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint-iop.sh"]

CMD ["apache2-foreground"]
