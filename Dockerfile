# Stage 1: Frontend Build
FROM node:20-alpine AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package*.json ./
RUN npm ci --only=production || npm install

COPY frontend/ ./
RUN npm run build

# Stage 2: Backend Build
FROM gradle:9.2.1-jdk21 AS backend-builder

WORKDIR /app

COPY build.gradle.kts settings.gradle.kts ./
COPY src/ ./src/
COPY --from=frontend-builder /app/frontend/dist ./src/main/resources/static

RUN gradle clean build -x test --no-daemon

# Stage 3: Final Runtime Image
FROM eclipse-temurin:21-jre-alpine AS runtime

RUN apk add --no-cache curl && \
    addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -D appuser

WORKDIR /app

COPY --from=backend-builder /app/build/libs/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m"

EXPOSE 8080 9090

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]