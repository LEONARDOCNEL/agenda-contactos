FROM php:8.2-apache

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

COPY . /var/www/html/

RUN mv /var/www/html/backend/* /var/www/html/ 2>/dev/null || true

RUN echo 'Listen ${PORT}' > /etc/apache2/ports.conf
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf
RUN sed -i 's/:80>/:${PORT}>/g' /etc/apache2/sites-available/000-default.conf

RUN echo 'FallbackResource /index.php' >> /etc/apache2/apache2.conf

CMD ["apache2-foreground"]