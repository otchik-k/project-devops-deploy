# =============================================================================
# Stage 1: Frontend Build
# =============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Копируем манифесты зависимостей
COPY frontend/package*.json ./

# Устанавливаем ВСЕ зависимости (vite находится в devDependencies)
RUN npm ci

# Копируем исходный код
COPY frontend/ ./

# Запускаем сборку (результат будет в /app/frontend/dist)
RUN npm run build

# =============================================================================
# Stage 2: Backend Build
# =============================================================================
FROM gradle:9.2.1-jdk21 AS backend-builder

WORKDIR /app

# 1. Копируем конфигурацию Gradle первыми для использования кэша слоев
COPY build.gradle.kts settings.gradle.kts ./
# Если есть файл gradle.properties, его тоже лучше скопировать
COPY gradle.properties* ./

# 2. Копируем исходный код бэкенда
COPY src/ ./src/

# 3. Копируем собранный фронтенд из предыдущей стадии в ресурсы Spring Boot
# Важно: путь должен точно соответствовать структуре ресурсов Spring
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static

# 4. Сборка проекта
# Используем --no-daemon для Docker (демон не нужен в одноразовом контейнере)
# -x test пропускает тесты (для CI/CD часто желательно, можно убрать если нужны тесты)
# --stacktrace выведет подробную ошибку, если сборка упадет снова
RUN gradle clean build -x test --no-daemon --stacktrace

# =============================================================================
# Stage 3: Final Runtime Image
# =============================================================================
FROM eclipse-temurin:21-jre-alpine AS runtime

# Установка утилит и создание пользователя для безопасности
RUN apk add --no-cache curl && \
    addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app

# Копируем готовый JAR из стадии сборки
# Используем wildcard, чтобы не зависеть от точного имени версии в названии файла
COPY --from=backend-builder /app/build/libs/*.jar app.jar

# Настройка прав доступа
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

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]