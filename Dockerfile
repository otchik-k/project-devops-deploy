# ─────────────────────────────────────────────
# Stage 1 — сборка фронтенда
# ─────────────────────────────────────────────
FROM node:24-slim AS frontend-build

WORKDIR /app/frontend

# Кешируем зависимости
COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci

# Копируем исходники и собираем
COPY frontend/ ./
RUN npm run build          # результат — в frontend/dist

# ─────────────────────────────────────────────
# Stage 2 — сборка бэкенда
# ─────────────────────────────────────────────
FROM eclipse-temurin:21-jdk AS backend-build

WORKDIR /app

# Копируем Gradle-файлы для кеширования
COPY gradle/ gradle/
COPY gradlew build.gradle settings.gradle ./
RUN chmod +x gradlew

# Скачиваем зависимости
RUN ./gradlew dependencies --no-daemon

# Копируем исходники бэкенда
COPY src/ src/

# Встраиваем собранный фронтенд в static-ресурсы
# Сначала очищаем, потом копируем из стадии сборки фронтенда
RUN rm -rf src/main/resources/static \
    && mkdir -p src/main/resources/static

COPY --from=frontend-build /app/frontend/dist/ src/main/resources/static/

# Собираем JAR
RUN ./gradlew bootJar --no-daemon

# ─────────────────────────────────────────────
# Stage 3 — runtime (только JRE)
# ─────────────────────────────────────────────
FROM eclipse-temurin:21-jre AS runtime

WORKDIR /app

LABEL org.opencontainers.image.title="project-devops-deploy" \
      org.opencontainers.image.description="Bulletin board service"

# Устанавливаем curl для работы HEALTHCHECK (в slim/jre образах его нет)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*

# Копируем собранный JAR
COPY --from=backend-build /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar app.jar

# Папка для локального хранилища изображений (dev-профиль)
RUN mkdir -p /tmp/bulletin-images

# Порты: 8080 — приложение, 9090 — Actuator/management
EXPOSE 8080 9090

# HEALTHCHECK: проверяем /actuator/health на порту 9090 (дефолт)
# Если порт будет изменен через MANAGEMENT_SERVER_PORT, эта проверка может не сработать,
# пока приложение не перечитает конфиг, но обычно порт меняется сразу при старте.
# Для продакшена лучше явно указывать 9090, так как это стандарт де-факто.
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

# JAVA_OPTS пробрасывается через env (Ansible / docker run)
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS:-\"\"} -jar /app/app.jar"]
