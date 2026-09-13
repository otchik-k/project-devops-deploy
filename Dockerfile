
# ---- Этап 1: сборка фронтенда ----
FROM node:20-alpine AS frontend-builder

WORKDIR /frontend
COPY frontend/ .
RUN npm ci
RUN npm run build

# ---- Этап 2: сборка бэкенда (Gradle + Java) ----
FROM gradle:9-jdk21 AS backend-builder

WORKDIR /app
COPY . .
COPY --from=frontend-builder /frontend/dist /app/src/main/resources/static/
RUN ./gradlew build

# ---- ЭТАП 3: Финальный образ (только JRE) ----
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Копируем ВСЮ папку целиком
COPY --from=backend-builder /app /app
ENV JAVA_OPTS=""
EXPOSE 8080
EXPOSE 9090

# Запускаем по точному пути из README
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar"]
