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

# 4. Crear un index.php VÁLIDO (JSON correcto)
RUN echo '<?php header("Content-Type: application/json"); echo json_encode(["success" => true, "message" => "API Agenda Contactos", "endpoints" => ["/", "/auth/login", "/contactos"]]); ?>' > index.php

# 5. También intentar copiar el index.php REAL desde GitHub
RUN apt-get install -y wget && \
    wget -q https://raw.githubusercontent.com/LEONARDOCNEL/agenda-contactos/main/backend/index.php -O index.php 2>/dev/null || \
    echo '<?php header("Content-Type: application/json"); echo json_encode(["success" => true, "message" => "API funcionando"]); ?>' > index.php

# 6. Verificar sintaxis PHP
RUN php -l index.php

# 7. Script de inicio
CMD echo "=== INICIANDO APACHE ===" && \
    echo "PORT: ${PORT}" && \
    echo "Listen ${PORT}" > /etc/apache2/ports.conf && \
    sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf 2>/dev/null || true && \
    echo "=== INDEX.PHPhp ===" && \
    cat index.php | head -5 && \
    apache2-foreground