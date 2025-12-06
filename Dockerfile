FROM php:8.2-apache

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# 1. Copiar backend
COPY backend/ /var/www/html/

# 2. Configuración CRÍTICA para Apache
RUN echo '<VirtualHost *:${PORT}>' > /etc/apache2/sites-available/000-default.conf
RUN echo '    DocumentRoot /var/www/html' >> /etc/apache2/sites-available/000-default.conf
RUN echo '    <Directory /var/www/html>' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        Options -Indexes +FollowSymLinks' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        AllowOverride All' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        Require all granted' >> /etc/apache2/sites-available/000-default.conf
RUN echo '        DirectoryIndex index.php' >> /etc/apache2/sites-available/000-default.conf
RUN echo '    </Directory>' >> /etc/apache2/sites-available/000-default.conf
RUN echo '</VirtualHost>' >> /etc/apache2/sites-available/000-default.conf

# 3. Puerto de Render
RUN echo 'Listen ${PORT}' > /etc/apache2/ports.conf

# 4. Habilitar mod_rewrite
RUN a2enmod rewrite

# 5. Crear .htaccess automáticamente
RUN echo 'RewriteEngine On' > /var/www/html/.htaccess
RUN echo 'RewriteCond %{REQUEST_FILENAME} !-f' >> /var/www/html/.htaccess
RUN echo 'RewriteCond %{REQUEST_FILENAME} !-d' >> /var/www/html/.htaccess
RUN echo 'RewriteRule ^ index.php [QSA,L]' >> /var/www/html/.htaccess

CMD ["apache2-foreground"]