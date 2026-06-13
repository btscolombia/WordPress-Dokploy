FROM php:8.2-apache

# Run Apache as 'nobody' to match WordPress file ownership (OpenLiteSpeed uses nobody:nogroup)
ENV APACHE_RUN_USER=nobody
ENV APACHE_RUN_GROUP=nogroup

# Enable mod_rewrite
RUN a2enmod rewrite

# Download the latest official Tiny File Manager
RUN curl -o /var/www/html/index.php https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php

# Fix ownership of Tiny File Manager's own files
RUN chown -R nobody:nogroup /var/www/html
