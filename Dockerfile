# Official WordPress image on DockerHub: https://hub.docker.com/_/wordpress/
# Check for the latest tags there
FROM wordpress:5.7.2-php7.4-apache

LABEL version="0.7.8"

# Add `wp` user and group, then add `www-data` user to `wp` group
RUN addgroup  --gid 1000 wp \
    && useradd -u 1000 -d /home/wp -g wp -G www-data wp \
    && usermod -a -G wp www-data

# All new files should be group-writable
RUN echo 'umask 002' >> /etc/profile.d/set-umask.sh

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

# Install the Intl extension
RUN apt-get update -yqq \
    && apt-get install -y libicu-dev \
    && docker-php-ext-install intl

# Install Memcached
RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
      libmemcached-dev \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install memcached \
    && docker-php-ext-enable memcached

# Install XDebug, largly copied from:
# https://github.com/andreccosta/wordpress-xdebug-dockerbuild
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && echo "xdebug.profiler_enable_trigger = 1" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo "xdebug.profiler_output_dir = /tmp/xdebug_profiler" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && echo "debug.remote_host = host.docker.internal" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini \
    && rm -rf /tmp/pear
    # && echo "xdebug.remote_enable = 1" >> /usr/local/etc/php/conf.d/z_iop-xdebug.ini
    # && echo "xdebug.remote_autostart=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # && echo "xdebug.remote_port=${XDEBUG_PORT}" >> /usr/local/etc/php/conf.d/xdebug.ini \
    # && echo "xdebug.idekey=${XDEBUG_IDEKEY}" >> /usr/local/etc/php/conf.d/xdebug.ini

# Remove 10 MB /usr/src/php.tar.xz file. It's iunnecesary since we're not upda5ting PHP without rebuilding.
# Ref: https://github.com/docker-library/php/issues/488
RUN rm /usr/src/php.tar.xz /usr/src/php.tar.xz.asc

# Make sure the XDebug profiler directory exists and is writable by www-data
RUN mkdir /tmp/xdebug_profiler \
    && chown www-data:www-data /tmp/xdebug_profiler

# Setup alternate WordPress debug.log location in /var/log
RUN mkdir -p /var/log/wordpress \
    && touch /var/log/wordpress/debug.log \
    && chown -R www-data:www-data /var/log/wordpress

# Install npm so we can run npx sort-package-json from the init script
RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
      npm \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global sort-package-json@1.48

# Install rsync, ssh-client and jq for merging tooling and package.json files
RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
      rsync \
      openssh-client \
      jq \
    && rm -rf /var/lib/apt/lists/*

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

# COPY default.config.js /usr/src/
COPY src/* /usr/src/
# COPY boilerplate-theme/ /usr/src/boilerplate-theme
COPY boilerplate-tooling/ /usr/src/boilerplate-tooling

# Network Debugging Tools
# TODO: Remove or disable if not needed
RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
      iputils-ping \
      dnsutils \
      vim \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts to /bin and make them executable
COPY bin/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Include our wp-config-extra.php file in wp-config-docker.php
RUN sed -i -E '/stop editing!/irequire("/usr/src/wp-config-extra.php");\n' /usr/src/wordpress/wp-config-docker.php

# Define default environment variables
ENV WORDPRESS_DB_HOST=db:3306
ENV WORDPRESS_DB_USER=wordpress
ENV WORDPRESS_DB_PASSWORD=wordpress
ENV WORDPRESS_DB_NAME=wordpress
ENV WORDPRESS_DEBUG=1

ENTRYPOINT ["docker-entrypoint-iop.sh"]

CMD ["apache2-foreground"]
