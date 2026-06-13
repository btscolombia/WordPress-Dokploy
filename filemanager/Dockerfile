FROM php:8.2-apache

# Habilitar mod_rewrite si es necesario
RUN a2enmod rewrite

# Descargar la última versión oficial de Tiny File Manager y guardarla como index.php
RUN curl -o /var/www/html/index.php https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php

# Dar permisos correctos (opcional pero recomendado)
RUN chown -R www-data:www-data /var/www/html
