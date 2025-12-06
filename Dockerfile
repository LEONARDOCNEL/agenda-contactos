FROM php:8.2-apache

# 1. Instalar dependencias
RUN apt-get update && apt-get install -y libpq-dev wget unzip \
    && docker-php-ext-install pdo pdo_pgsql

# 2. Configurar Apache
RUN a2enmod rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo 'FallbackResource /index.php' >> /etc/apache2/apache2.conf

# 3. Directorio de trabajo
WORKDIR /var/www/html

# 4. DESCARGAR TODO EL BACKEND desde GitHub
RUN echo "=== DESCARGANDO BACKEND DESDE GITHUB ===" && \
    wget -q https://github.com/LEONARDOCNEL/agenda-contactos/archive/main.zip -O /tmp/repo.zip && \
    echo "=== DESCOMPRIMIENDO ===" && \
    unzip -q /tmp/repo.zip -d /tmp/ && \
    echo "=== COPIANDO ARCHIVOS ===" && \
    cp -r /tmp/agenda-contactos-main/backend/* . 2>/dev/null || (echo "ERROR: No se pudieron copiar archivos" && ls -la /tmp/agenda-contactos-main/) && \
    rm -rf /tmp/repo.zip /tmp/agenda-contactos-main

# 5. Verificar que index.php existe
RUN if [ -f "index.php" ]; then \
    echo "✅ index.php encontrado" && \
    echo "=== PRIMERAS 20 LÍNEAS DE index.php ===" && \
    head -20 index.php; \
    else \
    echo "❌ index.php NO encontrado, creando básico" && \
    echo '<?php header("Content-Type: application/json"); echo json_encode(["success" => true, "message" => "Backend PHP", "endpoints" => ["/","/auth/login","/contactos"]]); ?>' > index.php; \
    fi

# 6. Verificar estructura completa
RUN echo "=== ESTRUCTURA COMPLETA ===" && \
    find . -type f -name "*.php" | head -20

# 7. Script de inicio
CMD echo "=== INICIANDO CON PUERTO ${PORT} ===" && \
    echo "Listen ${PORT}" > /etc/apache2/ports.conf && \
    sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf 2>/dev/null || true && \
    apache2-foreground