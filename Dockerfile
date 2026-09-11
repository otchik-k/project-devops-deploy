# ---------- Stage 1: сборка фронтенда ----------
FROM node:20-slim AS frontend-build

WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# ---------- Stage 2: сборка бэкенда ----------
FROM gradle:9.2.1-jdk21 AS backend-build

WORKDIR /app
COPY . .
COPY --from=frontend-build /app/frontend/dist ./src/main/resources/static
RUN gradle bootJar --no-daemon

# ---------- Stage 3: runtime ----------
FROM eclipse-temurin:21-jre

WORKDIR /app
COPY --from=backend-build /app/build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8080 9090

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]
