# Stage 1: Frontend Build
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

# Копируем только файлы зависимостей для кэширования слоя
COPY frontend/package*.json ./

# Устанавливаем ВСЕ зависимости (включая devDependencies для vite)
RUN npm ci

# Копируем исходный код фронтенда
COPY frontend/ ./

# Запускаем сборку
RUN npm run build

# Stage 2: Backend Build
FROM gradle:9.2.1-jdk21 AS backend-builder

WORKDIR /app

# Копируем конфигурацию Gradle для кэширования зависимостей
COPY build.gradle.kts settings.gradle.kts ./
COPY src/ ./src/

# Копируем собранный фронтенд в ресурсы Spring Boot
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static

# Собираем проект (пропускаем тесты для ускорения сборки в CI/Docker)
RUN gradle clean build -x test --no-daemon

# Stage 3: Final Runtime Image
FROM eclipse-temurin:21-jre-alpine AS runtime

# Устанавливаем curl для healthcheck и создаем пользователя
RUN apk add --no-cache curl && \
    addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app

# Копиим готовый JAR из стадии сборки
COPY --from=backend-builder /app/build/libs/*.jar app.jar

# Настраиваем права доступа
RUN chown -R appuser:appgroup /app

USER appuser

# Переменные окружения по умолчанию (можно переопределить через docker run -e или Ansible)
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"
# Важно: порт actuator задается через переменную, но по умолчанию Spring использует 8080, 
# если MANAGEMENT_SERVER_PORT не передан. В продакшене лучше передавать явно.
ENV MANAGEMENT_SERVER_PORT=9090

EXPOSE 8080 9090

# Healthcheck с увеличенным временем старта (start-period), чтобы приложение успело подняться
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${MANAGEMENT_SERVER_PORT}/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]