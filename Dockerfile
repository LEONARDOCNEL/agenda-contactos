FROM php:8.2-apache

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

RUN a2enmod rewrite

# Copiar SOLO el backend al contenedor
COPY backend/ /var/www/html/

# Habilitar archivos .htaccess
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Configurar Apache para usar el puerto de Render
RUN echo 'Listen ${PORT}' > /etc/apache2/ports.conf
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf
RUN sed -i 's/:80>/:${PORT}>/g' /etc/apache2/sites-available/000-default.conf

# Establecer ServerName para evitar warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

EXPOSE ${PORT}

CMD ["apache2-foreground"]