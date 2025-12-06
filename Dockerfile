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

# 4. DESCARGAR y DEBUG DETALLADO
RUN echo "=== PASO 1: Descargando repo ===" && \
    wget -q https://github.com/LEONARDOCNEL/agenda-contactos/archive/main.zip -O /tmp/repo.zip && \
    echo "✅ Descargado" && \
    \
    echo "=== PASO 2: Descomprimiendo ===" && \
    unzip -q /tmp/repo.zip -d /tmp/ && \
    echo "✅ Descomprimido" && \
    \
    echo "=== PASO 3: Listando contenido ===" && \
    echo "📁 Contenido de /tmp/:" && \
    ls -la /tmp/ && \
    echo "📁 Contenido de /tmp/agenda-contactos-main/:" && \
    ls -la /tmp/agenda-contactos-main/ && \
    echo "📁 Contenido de /tmp/agenda-contactos-main/backend/:" && \
    ls -la /tmp/agenda-contactos-main/backend/ 2>/dev/null || echo "❌ NO existe backend/" && \
    \
    echo "=== PASO 4: Copiando ===" && \
    cp -r /tmp/agenda-contactos-main/backend/* . 2>/dev/null && \
    echo "✅ Copiado (si no hay error)" && \
    \
    echo "=== PASO 5: Limpiando ===" && \
    rm -rf /tmp/repo.zip /tmp/agenda-contactos-main

# 5. Verificar QUÉ se copió
RUN echo "=== CONTENIDO FINAL en /var/www/html ===" && \
    ls -la && \
    echo "=== ARCHIVOS PHP ENCONTRADOS ===" && \
    find . -name "*.php" | head -20

# 6. Script de inicio
CMD echo "=== INICIANDO CON PUERTO ${PORT} ===" && \
    echo "Listen ${PORT}" > /etc/apache2/ports.conf && \
    sed -i "s/:80>/:${PORT}>/g" /etc/apache2/sites-available/000-default.conf 2>/dev/null || true && \
    apache2-foreground