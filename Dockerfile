# Runtime image для запуска уже собранного приложения
FROM eclipse-temurin:21-jre

# Создаём пользователя для безопасности
RUN groupadd -r appgroup && useradd -r -g appgroup appuser

WORKDIR /app

# Копируем собранный JAR-файл из локальной сборки
COPY build/libs/project-devops-deploy-0.0.1-SNAPSHOT.jar app.jar

# Устанавливаем права на файл
RUN chown appuser:appgroup app.jar

# Переключаемся на не-root пользователя
USER appuser

# Открываем порты
# 8080 - основной порт приложения
# 9090 - порт для Actuator (мониторинг, health checks)
EXPOSE 8080 9090

# Health check через actuator endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:9090/actuator/health || exit 1

# Запуск приложения с поддержкой переменных окружения
# JAVA_OPTS передаётся через docker run -e или ansible
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]# Предполагается, что JAR находится в build/libs/ после выполнения make build