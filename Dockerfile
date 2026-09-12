# =============================================================================
# Stage 1: Frontend Build
# =============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# 1. Копируем манифесты зависимостей
COPY frontend/package*.json ./

# 2. Устанавливаем ВСЕ зависимости (включая devDependencies для vite)
RUN npm ci

# 3. Копируем весь исходный код фронтенда
COPY frontend/ ./

# 4. Собираем проект
# Vite создаст папку dist внутри текущей директории
RUN npm run build

# =============================================================================
# Stage 2: Backend Build
# =============================================================================
FROM gradle:9.2.1-jdk21 AS backend-builder

WORKDIR /app

# 1. Копируем файлы конфигурации Gradle первыми для кэширования слоя зависимостей
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle/ ./gradle/

# 2. Скачиваем зависимости (без компиляции кода)
RUN gradle dependencies --no-daemon

# 3. Копируем исходный код бэкенда
COPY src/ ./src/

# 4. Копируем собранный фронтенд из Stage 1
# Важно: копируем содержимое dist в папку static ресурсов Spring Boot
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static

# 5. СобираемJAR-файл
# -x test: пропускаем тесты
# --no-daemon: экономит ресурсы в контейнере
# --stacktrace --info: подробный лог ошибок
RUN gradle clean build -x test --no-daemon --stacktrace --info

# =============================================================================
# Stage 3: Final Runtime Image
# =============================================================================
FROM eclipse-temurin:21-jre-alpine AS runtime

# Установка curl для healthcheck и создание пользователя без root-прав
RUN apk add --no-cache curl && \
    addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app

# Копируем готовый JAR из стадии сборки
# Используем wildcard, но убедимся, что там один файл, или явно укажите имя, если оно фиксировано
COPY --from=backend-builder /app/build/libs/*.jar app.jar

# Настраиваем права доступа
RUN chown -R appuser:appgroup /app

USER appuser

# Переменные окружения
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENV MANAGEMENT_SERVER_PORT=9090

EXPOSE 8080 9090

# Healthcheck с увеличенным временем старта
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${MANAGEMENT_SERVER_PORT}/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"