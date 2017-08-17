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
    rpm -Uvh https://dl.iuscommunity.org/pub/ius/stable/CentOS/7/x86_64/ius-release-1.0-14.ius.centos7.noarch.rpm

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

# Download Mediawiki
RUN cd /tmp/ && wget https://releases.wikimedia.org/mediawiki/$MEDIAWIKI_VERSION/mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz && \
	wget https://extdist.wmflabs.org/dist/extensions/LdapAuthentication-$LDAPEXT_VERSION.tar.gz && \
	tar xzvf mediawiki-$MEDIAWIKI_FULL_VERSION.tar.gz -C /usr/src/ && \
	tar xzvf tar -xzf LdapAuthentication-$LDAPEXT_VERSION.tar.gz -C /usr/src/mediawiki*/extensions/ && \
	rm -rf /tmp/mediawiki* /tmp/LdapAuthentication-REL*

# Copy run-httpd script to image
ADD ./conf.d/run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

EXPOSE 80 443

CMD ["/run-httpd.sh"]

