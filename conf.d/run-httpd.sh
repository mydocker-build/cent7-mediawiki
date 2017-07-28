#!/bin/bash

DIR="/var/www/html"

# Check if /var/www/html empty or not
if [ "$(ls -A $DIR)" ]; then
     echo "Enjoy your MediaWiki ...!"
else
    echo "Copy mediawiki source to webroot ...!"
    cp -r /usr/src/mediawiki*/* /var/www/html/
    chmod 755 /var/www/html
    chown -R apache:apache /var/www/html
fi

# Make sure we're not confused by old, incompletely-shutdown httpd
# context after restarting the container.  httpd won't start correctly
# if it thinks it is already running.
rm -rf /run/httpd/* /tmp/httpd*

exec /usr/sbin/apachectl -DFOREGROUND
