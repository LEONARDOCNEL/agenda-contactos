FROM php:8.2-apache

# Instalar PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# Crear directorio de trabajo
WORKDIR /var/www/html

# COPIAR EXPLÍCITAMENTE cada carpeta
COPY backend/index.php .
COPY backend/api/ api/
COPY backend/.htaccess .

# Listar para verificar
RUN ls -la && \
    echo "=== Archivos copiados ===" && \
    find . -type f -name "*.php" | head -20

# Configuración MINIMA de Apache
RUN echo "Listen ${PORT}" > /etc/apache2/ports.conf && \
    sed -i "s/Listen 80/Listen ${PORT}/g" /etc/apache2/ports.conf

# Habilitar mod_rewrite
RUN a2enmod rewrite

# Configurar que todas las rutas vayan a index.php
RUN echo 'FallbackResource /index.php' >> /etc/apache2/apache2.conf

CMD ["apache2-foreground"]