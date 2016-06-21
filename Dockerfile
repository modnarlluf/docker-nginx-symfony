FROM debian:jessie

RUN apt-get -y update && apt-get -y install wget curl

COPY conf/dotdeb.list /etc/apt/sources.list.d/
RUN wget https://www.dotdeb.org/dotdeb.gpg && apt-key add dotdeb.gpg

RUN apt-get -y update
RUN apt-get -y install nginx-extras imagemagick \
        php7.0-fpm php7.0-intl php7.0-mysql php7.0-curl php7.0-json php7.0-gd php7.0-mcrypt php7.0-json php7.0-pgsql \
        php7.0-readline php7.0-sqlite3

ADD conf/nginx/nginx.conf /etc/nginx/
ADD conf/nginx/default /etc/nginx/sites-available/

RUN echo "upstream php-upstream { server unix:/run/php/php7.0-fpm.sock; }" > /etc/nginx/conf.d/upstream.conf

RUN usermod -u 1000 www-data

ENV APP_PATH /var/www/app

RUN mkdir -p $APP_PATH
RUN chown www-data:www-data $APP_PATH
WORKDIR $APP_PATH

RUN wget -O composer.phar https://getcomposer.org/composer.phar && chmod a+x composer.phar && mv composer.phar /usr/local/bin/composer

EXPOSE 80 443

COPY startup.sh /
ENTRYPOINT ["/startup.sh"]