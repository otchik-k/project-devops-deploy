FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN npm run build

FROM gradle:8-jdk21 AS backend-build
WORKDIR /app
COPY . .
COPY --from=frontend-build /app/frontend/dist/. src/main/resources/static/
RUN ./gradlew bootJar

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=backend-build /app/build/libs/*.jar /app/app.jar
EXPOSE 8080 9090

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget -q --spider http://localhost:9090/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
