FROM coolfool/php5-jessie-multi:zts-5.6.25

ENV EBOT_HOME="/ebot" \
    TIMEZONE="Europe/Paris"

RUN curl -fsSL https://deb.nodesource.com/setup_4.x | bash - && \
    apt-get install nodejs -y --force-yes 

RUN apt-get install -y netcat git php5-curl && apt-get clean && \
    mkdir ${EBOT_HOME} && \
    npm install socket.io@0.9.12 archiver@0.4.10 formidable@1.2.1 && \
    npm install -g forever@v0.15.3 

RUN pecl install pthreads-2.0.10 && \
    docker-php-ext-enable pthreads && \
    docker-php-ext-install mysql sockets 

RUN echo 'date.timezone = "${TIMEZONE}"' >> /usr/local/etc/php/conf.d/php.ini && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/bin && \
    php -r "unlink('composer-setup.php');" && \
    git clone https://github.com/deStrO/eBot-CSGO.git "$EBOT_HOME" && \
    cd "$EBOT_HOME" && git checkout "master" && \
    /usr/local/bin/php /usr/bin/composer.phar install && \
    cp "$EBOT_HOME"/config/config.ini.smp "$EBOT_HOME"/config/config.ini

WORKDIR ${EBOT_HOME}

COPY entrypoint.sh /sbin/entrypoint.sh

RUN chmod +x /sbin/entrypoint.sh

EXPOSE 12360 12360/udp 12361/udp

ENTRYPOINT ["/sbin/entrypoint.sh"]
