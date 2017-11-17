## Modified by Sam KUON - 28/05/17
FROM centos:latest
MAINTAINER Sam KUON "sam.kuonssp@gmail.com"

ENV MEDIAWIKI_VERSION 1.29
ENV MEDIAWIKI_FULL_VERSION 1.29.0
ENV LDAPEXT_VERSION REL1_29-4c9bdab

# System timezone
ENV TZ=Asia/Phnom_Penh
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Repositories and packages
RUN yum -y install epel-release && \
	curl -s https://setup.ius.io/ | bash

RUN yum -y update && \
    yum -y install \
	php70u \
	php70u-mysqlnd \
	php70u-xml \
	php70u-intl \
	php70u-gd \
	php70u-mbstring \
	php70u-pear \
	mod_php70u \
	php70u-json \
	php70u-ldap \
	ImageMagick-perl \
	texlive \
	httpd \
	wget &&\
    yum clean all

# Set Timzone in PHP
RUN sed -i '890idate.timezone = "Asia/Phnom_Penh"' /etc/php.ini

# Secure Apache server
## Disable CentOS Welcome Page
RUN sed -i 's/^\([^#]\)/#\1/g' /etc/httpd/conf.d/welcome.conf

## Turn off directory listing, Disable Apache's FollowSymLinks, Turn off server-side includes (SSI) and CGI execution
RUN cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig && \
	sed -i 's/^\([^#]*\)Options Indexes FollowSymLinks/\1Options -Indexes +SymLinksifOwnerMatch -ExecCGI -Includes/g' /etc/httpd/conf/httpd.conf

## Hide the Apache version, secure from clickjacking attacks, disable ETag, secure from XSS attacks and protect cookies with HTTPOnly flag
RUN echo $'\n\
ServerSignature Off\n\
ServerTokens Prod\n\
Header append X-FRAME-OPTIONS "SAMEORIGIN"\n\
FileETag None\n\
<IfModule mod_headers.c>\n\
    Header set X-XSS-Protection "1; mode=block"\n\
</IfModule>\n'\
>> /etc/httpd/conf/httpd.conf

# Disable unnecessary modules in /etc/httpd/conf.modules.d/00-base.conf
RUN cp /etc/httpd/conf.modules.d/00-base.conf /etc/httpd/conf.modules.d/00-base.conf.bak && \
	sed -i '/mod_cache.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
	sed -i '/mod_cache_disk.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
	sed -i '/mod_substitute.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf && \
	sed -i '/mod_userdir.so/ s/^/#/' /etc/httpd/conf.modules.d/00-base.conf

# Disable everything in /etc/httpd/conf.modules.d/00-dav.conf, 00-lua.conf, 00-proxy.conf and 01-cgi.conf
RUN sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-dav.conf && \
	sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-lua.conf && \
	sed -i 's/^/#/g' /etc/httpd/conf.modules.d/00-proxy.conf && \
	sed -i 's/^/#/g' /etc/httpd/conf.modules.d/01-cgi.conf

# Download Mediawiki
RUN cd /tmp/ && wget https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz && \
	wget https://extdist.wmflabs.org/dist/extensions/LdapAuthentication-$LDAPEXT_VERSION.tar.gz && \
	tar -xvzf mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz -C /usr/src/ && \
	tar -xvzf LdapAuthentication-$LDAPEXT_VERSION.tar.gz -C /usr/src/mediawiki*/extensions/ && \
	rm -rf /tmp/*

# Copy run-httpd script to image
ADD ./conf.d/run-httpd.sh /run-httpd.sh
ADD ./conf.d/apache_state.conf /etc/httpd/conf.d/apache_state.conf
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

CMD ["/run-httpd.sh"]

