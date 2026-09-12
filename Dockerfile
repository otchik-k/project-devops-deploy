# =============================================================================
# Stage 1: Frontend Build
# =============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Копируем package.json для кэширования слоя зависимостей
COPY frontend/package*.json ./

# Устанавливаем ВСЕ зависимости (vite нужен для сборки)
RUN npm ci

# Копируем исходный код
COPY frontend/ ./

# Запускаем сборку
RUN npm run build

# =============================================================================
# Stage 2: Backend Build
# =============================================================================
FROM gradle:9.2.1-jdk21 AS backend-builder

WORKDIR /app

# Копируем файлы конфигурации Gradle первыми для кэширования
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle/ ./gradle/

# Копируем исходный код бэкенда
COPY src/ ./src/

# Копируем собранный фронтенд в ресурсы Spring Boot
# Важно: путь должен совпадать с тем, где лежит dist после npm run build
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static

# Собираем проект
# -x test : пропускаем тесты (для CI/CD часто желательно)
# --no-daemon : обязательно для Docker, чтобы не висел процесс демона
# --stacktrace : подробный лог ошибок
RUN gradle clean build -x test --no-daemon --stacktrace

# =============================================================================
# Stage 3: Final Runtime Image
# =============================================================================
FROM eclipse-temurin:21-jre-alpine AS runtime

# Устанавливаем curl для healthcheck и создаем пользователя для безопасности
RUN apk add --no-cache curl && \
    addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app

# Копируем JAR файл
COPY --from=backend-builder /app/build/libs/*.jar app.jar

# Настраиваем права
RUN chown -R appuser:appgroup /app

USER appuser

# Переменные окружения по умолчанию
# В продакшене они будут переопределены через Ansible/Docker Compose
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENV MANAGEMENT_SERVER_PORT=9090
ENV SERVER_PORT=8080

EXPOSE 8080 9090

# Healthcheck:
# --start-period=60s дает приложению 60 секунд на первый запуск перед тем, как считать его unhealthy
# Используем переменную ${MANAGEMENT_SERVER_PORT}, так как она может быть переопределена
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${MANAGEMENT_SERVER_PORT}/actuator/health || exit 1

# Запуск приложения
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]