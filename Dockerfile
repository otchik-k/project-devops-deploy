FROM eclipse-temurin:21-jdk-alpine AS builder

# Установка зависимостей для сборки фронтенда
RUN apk add --no-cache nodejs npm make git curl

WORKDIR /app

# Копируем исходники
COPY . .

# --- Сборка Фронтенда ---
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Возвращаемся в корень для сборки Бэкенда
WORKDIR /app
# Сборка Spring Boot приложения (создаст jar в build/libs/)
RUN ./gradlew clean bootJar -x test

# --- Финальный образ ---
FROM eclipse-temurin:21-jre-alpine

# Переменные окружения для режима DEV
ENV SPRING_PROFILES_ACTIVE=dev \
    MANAGEMENT_SERVER_PORT=9090 \
    JAVA_OPTS="-Xms256m -Xmx512m"

# Создаем пользователя для безопасности (не root)
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser

USER appuser
WORKDIR /home/appuser

# Копируем артефакты из стадии builder
# 1. Jar файл бэкенда
COPY --from=builder /app/build/libs/project-devops-deploy-*.jar app.jar
# 2. Статические файлы фронтенда (dist) в папку static, которую Spring автоматически отдает
COPY --from=builder /app/frontend/dist /home/appuser/static

# Точка монтирования для временных файлов (изображения в dev режиме)
VOLUME ["/home/appuser/images"]

# Порты: 8080 (API + Frontend), 9090 (Actuator/Monitoring)
EXPOSE 8080 9090

# Команда запуска
# Мы не используем Vite dev server, а отдаем собранный dist через Spring Boot.
# Это единственный способ запустить React и Spring в одном процессе.
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
