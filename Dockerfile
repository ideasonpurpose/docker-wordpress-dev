# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
# Suppresses a Docker warning when setting the WORDPRESS_DB_PASSWORD env var

# Official WordPress image on DockerHub:
# https://hub.docker.com/_/wordpress/
# This version is automatically updated by the wordpress:bump script
# but can also be manually updated for tagged betas and release candidates
# Manual updates also must change wp-version.json
FROM wordpress:6.9.4-php8.4-apache

LABEL version="1.9.3"

# Remove 10 MB /usr/src/php.tar.xz file. Unnecessary since we never update PHP without rebuilding.
# Ref: https://github.com/docker-library/php/issues/488
# TODO: Is this still necessary?
RUN rm /usr/src/php.tar.xz /usr/src/php.tar.xz.asc

# Add `wp` user and group, then add `www-data` user to `wp` group
RUN addgroup  --gid 1000 wp \
    && useradd -u 1000 -d /home/wp -g wp -G www-data wp \
    && usermod -a -G wp www-data

# Set global umask with pam_umask
RUN echo >> /etc/pam.d/common-session \
    && echo '# Set umask so newly created files are group writeable' >> /etc/pam.d/common-session \
    && echo 'session optional pam_umask.so umask=002' >> /etc/pam.d/common-session

# Set umask for Apache & PHP so new files are group-writable
RUN echo >> /etc/apache2/envvars \
    && echo '# Set umask so newly created files are group writeable' >> /etc/apache2/envvars \
    && echo 'umask 002' >> /etc/apache2/envvars

# Set Apache ServerName globally to address slowdowns
RUN echo "ServerName localhost" > /etc/apache2/conf-available/server-name.conf \
    && a2enconf server-name

# Configure PHP
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
    && echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/z_iop-debug.ini \
    && echo "short_open_tag = off" >> /usr/local/etc/php/conf.d/z_iop-debug.ini

RUN echo "[OPcache]" > /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.enable=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.revalidate_freq=0" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.validate_timestamps=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.max_accelerated_files=10000" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.memory_consumption=192" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.max_wasted_percentage=10" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.interned_strings_buffer=16" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini \
    && echo "opcache.fast_shutdown=1" >> /usr/local/etc/php/conf.d/z_iop-opcache.ini


# # Install PIE
# RUN curl -fL -o /usr/local/bin/pie https://github.com/php/pie/releases/latest/download/pie.phar \
#     && chmod +x /usr/local/bin/pie

# Install less for wp-cli's pager
# Install rsync, ssh-client and jq for merging tooling and package.json files
# Install IPTables to workaround WordPress internal requests to external ports
# - IPTables is used to remap Docker's entire ephemeral port range back to 80
# Install build dependencies for memcached extension
# Install PIE
#  - Install memcached
#  - Install xdebug
# Remove build dependencies and clean up
# Remove PIE
RUN apt-get update -yqq \
    && curl -fL -o /usr/local/bin/pie https://github.com/php/pie/releases/latest/download/pie.phar \
    && chmod +x /usr/local/bin/pie \
    && apt-get install -y --no-install-recommends \
        less \
        rsync \
        openssh-client \
        jq \
        iptables \
        bison \
        libtool \
        libmemcached-dev \
        zlib1g-dev \
    && pie install php-memcached/php-memcached \
    && docker-php-ext-enable memcached \
    && pie install xdebug/xdebug \
    && docker-php-ext-enable xdebug \
    && apt-get remove -yqq --purge bison libtool \
    && apt-get autoremove -yqq \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/local/bin/pie \
    && rm -rf /tmp/*



# # Install XDebug
# RUN pie install xdebug/xdebug \
#     && docker-php-ext-enable xdebug

# Configure XDebug
RUN echo '[XDebug]' > /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.mode = debug,profile' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.output_dir = /tmp/xdebug' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.start_with_request = trigger' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.client_host = host.docker.internal' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.client_port = 9003' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo 'xdebug.use_compression = false' >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini


# Make sure the XDebug profiler directory exists and is writable by www-data
RUN mkdir -p /tmp/xdebug \
    && chmod -R 777 /tmp/xdebug \
    && chown www-data:www-data /tmp/xdebug

# Install Composer, VarDumper and Kint
# Clean up the composer cache
RUN cd /usr/src \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer require symfony/var-dumper kint-php/kint --no-interaction \
    && composer clear-cache \
    && echo 'auto_prepend_file=/usr/src/debug_loader.php' > /usr/local/etc/php/conf.d/z_iop-debug_loader.ini \
    && rm -rf /root/.composer/cache \
    && rm -rf /usr/local/bin/composer \
    && rm -rf /tmp/*

COPY src/debug_loader.php /usr/src

# Setup alternate WordPress debug.log location in /var/log
RUN mkdir -p /var/log/wordpress \
    && touch /var/log/wordpress/debug.log \
    && chown -R www-data:www-data /var/log/wordpress


# Install wp-cli since the native image is a bowl of permissions errors
RUN curl https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Install LTS node.js from nodesource:
#     https://github.com/nodesource/distributions#installation-instructions
#     https://github.com/nodejs/release#release-schedule
# Also global install npm & sort-package-json so we can call them from the init script
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        nodejs \
    && npm install --global \
        npm \
        sort-package-json \
    && apt-get autoremove -yqq \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/*



# Setup location for wp user's SSH keys
RUN mkdir -p /ssh_keys \
    && chmod 0700 /ssh_keys \
    && chown wp:wp /ssh_keys

# Configure SSH
RUN echo >> /etc/ssh/ssh_config \
    && echo "# IOP Additions for automated connections" >> /etc/ssh/ssh_config \
    && echo "    IdentityFile /ssh_keys/id_rsa" >> /etc/ssh/ssh_config \
    && echo "    StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config \
    && echo "    LogLevel QUIET" >> /etc/ssh/ssh_config

COPY src/wp-config-extra.php /usr/src/


# Network Debugging Tools
# TODO: Remove or disable if not needed
# RUN apt-get update -yqq \
#     && apt-get install -y --no-install-recommends \
#         iputils-ping \
#         dnsutils \
#         vim \
#     && apt-get autoremove -yqq \
#     &&  rm -rf /var/lib/apt/lists/*


# Setup Message Of The Day
COPY motd motd/* /etc/update-motd.d/
RUN chmod +x /etc/update-motd.d/*

# Force MOTD in root bashrc
RUN echo \
    && echo LS_OPTIONS='--color=auto' >> /root/.bashrc \
    && echo run-parts /etc/update-motd.d/ >> /root/.bashrc \
    && echo alias wp='wp --allow-root' \
    && echo cd /usr/src >> /root/.bashrc

# Copy scripts to /bin and make them executable
COPY bin/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Include our wp-config-extra.php file in wp-config-docker.php
RUN sed -i -E '/stop editing!/i// Ideas On Purpose config additions. (optional for wp-cli)\
    \n@include "/usr/src/wp-config-extra.php";\n' /usr/src/wordpress/wp-config-docker.php

# Define default environment variables
ENV WORDPRESS_DB_HOST=db:3306
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_PASSWORD=wordpress
ENV WORDPRESS_DB_NAME=wordpress
ENV WORDPRESS_DEBUG=1

ENTRYPOINT ["docker-entrypoint-iop.sh"]

CMD ["apache2-foreground"]
