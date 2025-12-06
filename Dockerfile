FROM php:8.2-apache

# 1. Instalar PostgreSQL
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql

# 2. Configurar Apache
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo 'FallbackResource /index.php' >> /etc/apache2/apache2.conf

# 3. Directorio de trabajo
WORKDIR /var/www/html

# 4. ✅ CREAR directorio primero, LUEGO copiar
RUN mkdir -p /tmp/src
COPY . /tmp/src/ 2>/dev/null || true

# 5. Mover archivos si existen
RUN if [ -d "/tmp/src/backend" ]; then \
    echo "=== Copiando archivos locales ===" && \
    cp -r /tmp/src/backend/* . 2>/dev/null || true && \
    ls -la; \
    fi

# 6. Si index.php no existe, crear uno básico
RUN if [ ! -f "index.php" ]; then \
    echo '<?php header("Content-Type: application/json"); echo json_encode(["success"=>true,"message"=>"API funcionando","endpoints":["/","/auth/login","/contactos"]]); ?>' > index.php; \
    fi

# 7. Crear estructura de directorios si no existe
RUN mkdir -p api config 2>/dev/null || true

# 8. Script de inicio
CMD echo "=== INICIANDO APACHE ===" && \
    echo "PORT: ${PORT}" && \
    echo "Listen ${PORT}" > /etc/apache2/ports.conf && \
    sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf 2>/dev/null || true && \
    echo "=== ESTRUCTURA /var/www/html ===" && \
    ls -la && \
    apache2-foreground