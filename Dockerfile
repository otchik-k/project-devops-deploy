# ─────────────────────────────────────────────
# Dev Dockerfile — бекенд и фронтенд в одном контейнере
# Для локальной разработки с hot-reload
# ─────────────────────────────────────────────

FROM eclipse-temurin:21-jdk AS backend-base

WORKDIR /app

# Установка Node.js для сборки фронтенда
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Копируем Gradle-файлы для кеширования
COPY gradle/ gradle/
COPY gradlew ./
RUN chmod +x gradlew
COPY build.gradle* settings.gradle* gradle.properties* ./

# Скачиваем зависимости бекенда
RUN ./gradlew dependencies --no-daemon

# Копируем исходники бекенда
COPY src/ src/

# ─────────────────────────────────────────────
# Фронтенд
# ─────────────────────────────────────────────
WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci

COPY frontend/ ./

# ─────────────────────────────────────────────
# Runtime
# ─────────────────────────────────────────────
WORKDIR /app

EXPOSE 8080 9090 5173

# Переменные окружения для подключения к внешним сервисам
# SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/bulletins
# SPRING_DATASOURCE_USERNAME=postgres
# SPRING_DATASOURCE_PASSWORD=postgres
# STORAGE_S3_ENDPOINT=http://minio:9000
# STORAGE_S3_ACCESSKEY=minioadmin
# STORAGE_S3_SECRETKEY=minioadmin
# STORAGE_S3_BUCKET=bulletins
# STORAGE_S3_REGION=us-east-1

ENV SPRING_PROFILES_ACTIVE=dev

# Запускаем бекенд и фронтенд одновременно
# Бекенд: Spring Boot с devtools для hot-reload
# Фронтенд: Vite dev server с проксированием на бекенд
CMD ["sh", "-c", "(cd /app/frontend && npm run dev -- --host 0.0.0.0) & exec ./gradlew bootRun --no-daemon"]