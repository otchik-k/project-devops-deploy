# ─────────────────────────────────────────────
# Stage 1 — сборка фронтенда
# ─────────────────────────────────────────────
FROM node:24-slim AS frontend-build

WORKDIR /app/frontend

COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

# ─────────────────────────────────────────────
# Stage 2 — сборка бэкенда
# ─────────────────────────────────────────────
FROM eclipse-temurin:21-jdk AS backend-build

WORKDIR /app

# Копируем Gradle-файлы для кеширования (работает и с .gradle, и с .gradle.kts)
COPY gradle/ gradle/
COPY gradlew ./
RUN chmod +x gradlew
COPY build.gradle* settings.gradle* gradle.properties* ./

# Скачиваем зависимости
RUN ./gradlew dependencies --no-daemon

# Копируем исходники бэкенда
COPY src/ src/

# Встраиваем собранный фронтенд в static-ресурсы
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

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=backend-build /app/build/libs/*.jar app.jar

RUN mkdir -p /tmp/bulletin-images

EXPOSE 8080 9090

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS:-\"\"} -jar /app/app.jar"]
