FROM php:8.2-apache

RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

WORKDIR /var/www/html

# COPIAR TODO EL REPOSITORIO
COPY . /tmp/repo/

# MOVER solo lo necesario
RUN mv /tmp/repo/backend/* . 2>/dev/null || (echo "ERROR: No se pudo mover backend/" && ls -la /tmp/repo/)

# Verificar que los archivos están
RUN echo "=== CONTENIDO DE /var/www/html ===" && \
    ls -la && \
    echo "=== Archivos PHP encontrados ===" && \
    find . -name "*.php" | head -20

# Configurar Apache
RUN echo "Listen ${PORT}" > /etc/apache2/ports.conf
RUN sed -i "s/Listen 80/Listen ${PORT}/g" /etc/apache2/ports.conf
RUN echo 'FallbackResource /index.php' >> /etc/apache2/apache2.conf
RUN a2enmod rewrite

CMD ["apache2-foreground"]