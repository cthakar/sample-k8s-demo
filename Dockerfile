FROM centos:centos8
MAINTAINER Chintan Thakar <chintanthakar@hotmail.com>
ARG MEDIAWIKI_VERSION=1.36.2

# Install packages

RUN dnf module -y reset php \
    && dnf module -y enable php:7.4 \
    &&  dnf install -y wget httpd php php-mysqlnd php-gd php-xml php-mbstring php-json php-intl git \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Configuration
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf \
    && sed -i "s@#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@LoadModule mpm_prefork_module modules/mod_mpm_prefork.so@g" /etc/httpd/conf.modules.d/00-mpm.conf \
    && sed -i "s@LoadModule mpm_event_module modules/mod_mpm_event.so@#LoadModule mpm_event_module modules/mod_mpm_event.so@g" /etc/httpd/conf.modules.d/00-mpm.conf \
    && echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf \
    && sed -i 's@DocumentRoot "/var/www/html"@DocumentRoot "/var/www"@g' /etc/httpd/conf/httpd.conf

# Install mediawiki
RUN cd /var/www/ \
    && wget -q https://releases.wikimedia.org/mediawiki/1.36/mediawiki-${MEDIAWIKI_VERSION}.tar.gz \
    && tar -zxf mediawiki-${MEDIAWIKI_VERSION}.tar.gz \ 
    && mv mediawiki-${MEDIAWIKI_VERSION} mediawiki \ 
    && rm -rf mediawiki-${MEDIAWIKI_VERSION}.tar.gz


# UTC Timezone & Networking
RUN ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

EXPOSE 80
ENTRYPOINT ["/usr/sbin/httpd", "-D", "FOREGROUND"]