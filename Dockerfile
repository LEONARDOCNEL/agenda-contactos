FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

RUN a2enmod rewrite

COPY . /var/www/html/

RUN mv /var/www/html/backend/* /var/www/html/ 2>/dev/null || true

RUN echo 'Listen ${PORT}' > /etc/apache2/ports.conf
RUN sed -i 's/:80>/:${PORT}>/g' /etc/apache2/sites-available/000-default.conf

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE ${PORT}

CMD ["apache2-foreground"]