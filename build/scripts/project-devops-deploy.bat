@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem
@rem SPDX-License-Identifier: Apache-2.0
@rem

@if "%DEBUG%"=="" @echo off
@rem ##########################################################################
@rem
@rem  project-devops-deploy startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables, and ensure extensions are enabled
setlocal EnableExtensions

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
@rem This is normally unused
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and PROJECT_DEVOPS_DEPLOY_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo. 1>&2
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH. 1>&2
echo. 1>&2
echo Please set the JAVA_HOME variable in your environment to match the 1>&2
echo location of your Java installation. 1>&2

"%COMSPEC%" /c exit 1

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo. 1>&2
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME% 1>&2
echo. 1>&2
echo Please set the JAVA_HOME variable in your environment to match the 1>&2
echo location of your Java installation. 1>&2

"%COMSPEC%" /c exit 1

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\project-devops-deploy-0.0.1-SNAPSHOT-plain.jar;%APP_HOME%\lib\spring-boot-devtools-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-web-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-data-jpa-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-validation-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-actuator-4.1.1.jar;%APP_HOME%\lib\mapstruct-1.6.3.jar;%APP_HOME%\lib\instancio-core-6.0.0.jar;%APP_HOME%\lib\springdoc-openapi-starter-webmvc-ui-3.1.0.jar;%APP_HOME%\lib\micrometer-registry-prometheus-1.17.1.jar;%APP_HOME%\lib\jackson-databind-nullable-0.2.11.jar;%APP_HOME%\lib\datafaker-2.7.0.jar;%APP_HOME%\lib\s3-2.54.7.jar;%APP_HOME%\lib\logstash-logback-encoder-9.0.jar;%APP_HOME%\lib\h2-2.4.240.jar;%APP_HOME%\lib\postgresql-42.7.13.jar;%APP_HOME%\lib\spring-boot-starter-jackson-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-tomcat-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-jdbc-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-micrometer-metrics-4.1.1.jar;%APP_HOME%\lib\springdoc-openapi-starter-webmvc-api-3.1.0.jar;%APP_HOME%\lib\springdoc-openapi-starter-common-3.1.0.jar;%APP_HOME%\lib\spring-boot-starter-4.1.1.jar;%APP_HOME%\lib\spring-boot-actuator-autoconfigure-4.1.1.jar;%APP_HOME%\lib\spring-boot-autoconfigure-4.1.1.jar;%APP_HOME%\lib\spring-boot-webmvc-4.1.1.jar;%APP_HOME%\lib\spring-boot-http-converter-4.1.1.jar;%APP_HOME%\lib\spring-boot-data-jpa-4.1.1.jar;%APP_HOME%\lib\spring-boot-hibernate-4.1.1.jar;%APP_HOME%\lib\spring-boot-jpa-4.1.1.jar;%APP_HOME%\lib\spring-boot-jdbc-4.1.1.jar;%APP_HOME%\lib\spring-boot-validation-4.1.1.jar;%APP_HOME%\lib\spring-boot-health-4.1.1.jar;%APP_HOME%\lib\spring-boot-jackson-4.1.1.jar;%APP_HOME%\lib\spring-boot-servlet-4.1.1.jar;%APP_HOME%\lib\spring-boot-data-commons-4.1.1.jar;%APP_HOME%\lib\spring-boot-sql-4.1.1.jar;%APP_HOME%\lib\spring-boot-transaction-4.1.1.jar;%APP_HOME%\lib\spring-boot-micrometer-metrics-4.1.1.jar;%APP_HOME%\lib\spring-boot-actuator-4.1.1.jar;%APP_HOME%\lib\spring-boot-starter-tomcat-runtime-4.1.1.jar;%APP_HOME%\lib\spring-boot-tomcat-4.1.1.jar;%APP_HOME%\lib\spring-boot-web-server-4.1.1.jar;%APP_HOME%\lib\spring-boot-persistence-4.1.1.jar;%APP_HOME%\lib\spring-boot-micrometer-observation-4.1.1.jar;%APP_HOME%\lib\spring-boot-4.1.1.jar;%APP_HOME%\lib\micrometer-jakarta9-1.17.1.jar;%APP_HOME%\lib\hibernate-core-7.4.5.Final.jar;%APP_HOME%\lib\micrometer-core-1.17.1.jar;%APP_HOME%\lib\spring-webmvc-7.0.9.jar;%APP_HOME%\lib\spring-data-jpa-4.1.1.jar;%APP_HOME%\lib\spring-context-7.0.9.jar;%APP_HOME%\lib\spring-web-7.0.9.jar;%APP_HOME%\lib\micrometer-observation-1.17.1.jar;%APP_HOME%\lib\webjars-locator-lite-1.1.4.jar;%APP_HOME%\lib\spring-orm-7.0.9.jar;%APP_HOME%\lib\spring-jdbc-7.0.9.jar;%APP_HOME%\lib\spring-aop-7.0.9.jar;%APP_HOME%\lib\spring-data-commons-4.1.1.jar;%APP_HOME%\lib\spring-tx-7.0.9.jar;%APP_HOME%\lib\spring-beans-7.0.9.jar;%APP_HOME%\lib\spring-expression-7.0.9.jar;%APP_HOME%\lib\spring-core-7.0.9.jar;%APP_HOME%\lib\micrometer-commons-1.17.1.jar;%APP_HOME%\lib\jspecify-1.0.1.jar;%APP_HOME%\lib\aws-xml-protocol-2.54.7.jar;%APP_HOME%\lib\aws-query-protocol-2.54.7.jar;%APP_HOME%\lib\protocol-core-2.54.7.jar;%APP_HOME%\lib\aws-core-2.54.7.jar;%APP_HOME%\lib\auth-2.54.7.jar;%APP_HOME%\lib\regions-2.54.7.jar;%APP_HOME%\lib\sdk-core-2.54.7.jar;%APP_HOME%\lib\arns-2.54.7.jar;%APP_HOME%\lib\profiles-2.54.7.jar;%APP_HOME%\lib\crt-core-2.54.7.jar;%APP_HOME%\lib\http-auth-2.54.7.jar;%APP_HOME%\lib\http-auth-aws-2.54.7.jar;%APP_HOME%\lib\http-auth-spi-2.54.7.jar;%APP_HOME%\lib\identity-spi-2.54.7.jar;%APP_HOME%\lib\checksums-2.54.7.jar;%APP_HOME%\lib\retries-2.54.7.jar;%APP_HOME%\lib\retries-spi-2.54.7.jar;%APP_HOME%\lib\apache5-client-2.54.7.jar;%APP_HOME%\lib\netty-nio-client-2.54.7.jar;%APP_HOME%\lib\http-client-spi-2.54.7.jar;%APP_HOME%\lib\metrics-spi-2.54.7.jar;%APP_HOME%\lib\json-utils-2.54.7.jar;%APP_HOME%\lib\utils-2.54.7.jar;%APP_HOME%\lib\HikariCP-7.0.2.jar;%APP_HOME%\lib\httpclient5-5.6.4.jar;%APP_HOME%\lib\spring-boot-starter-logging-4.1.1.jar;%APP_HOME%\lib\logback-classic-1.5.38.jar;%APP_HOME%\lib\log4j-to-slf4j-2.25.5.jar;%APP_HOME%\lib\jul-to-slf4j-2.0.18.jar;%APP_HOME%\lib\swagger-core-jakarta-2.2.52.jar;%APP_HOME%\lib\slf4j-api-2.0.18.jar;%APP_HOME%\lib\swagger-ui-5.32.11.jar;%APP_HOME%\lib\prometheus-metrics-core-1.7.0.jar;%APP_HOME%\lib\prometheus-metrics-tracer-common-1.7.0.jar;%APP_HOME%\lib\prometheus-metrics-exposition-formats-1.7.0.jar;%APP_HOME%\lib\jackson-datatype-jsr310-2.21.5.jar;%APP_HOME%\lib\jackson-databind-2.21.5.jar;%APP_HOME%\lib\jackson-core-2.21.5.jar;%APP_HOME%\lib\jackson-dataformat-yaml-2.21.5.jar;%APP_HOME%\lib\snakeyaml-2.6.jar;%APP_HOME%\lib\rgxgen-3.1.jar;%APP_HOME%\lib\libphonenumber-9.0.33.jar;%APP_HOME%\lib\checksums-spi-2.54.7.jar;%APP_HOME%\lib\endpoints-spi-2.54.7.jar;%APP_HOME%\lib\http-auth-aws-eventstream-2.54.7.jar;%APP_HOME%\lib\utils-lite-2.54.7.jar;%APP_HOME%\lib\annotations-2.54.7.jar;%APP_HOME%\lib\jackson-core-3.1.5.jar;%APP_HOME%\lib\jackson-databind-3.1.5.jar;%APP_HOME%\lib\checker-qual-3.55.1.jar;%APP_HOME%\lib\jakarta.annotation-api-3.0.0.jar;%APP_HOME%\lib\spring-aspects-7.0.9.jar;%APP_HOME%\lib\tomcat-embed-el-11.0.24.jar;%APP_HOME%\lib\hibernate-validator-9.1.3.Final.jar;%APP_HOME%\lib\HdrHistogram-2.2.2.jar;%APP_HOME%\lib\prometheus-metrics-exposition-textformats-1.7.0.jar;%APP_HOME%\lib\prometheus-metrics-model-1.7.0.jar;%APP_HOME%\lib\prometheus-metrics-config-1.7.0.jar;%APP_HOME%\lib\reactive-streams-1.0.4.jar;%APP_HOME%\lib\eventstream-1.0.1.jar;%APP_HOME%\lib\third-party-jackson-core-2.54.7.jar;%APP_HOME%\lib\httpcore5-h2-5.4.3.jar;%APP_HOME%\lib\httpcore5-5.4.3.jar;%APP_HOME%\lib\netty-codec-http2-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-http-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-4.2.17.Final.jar;%APP_HOME%\lib\netty-handler-4.2.17.Final.jar;%APP_HOME%\lib\netty-transport-classes-epoll-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-compression-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-protobuf-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-marshalling-4.2.17.Final.jar;%APP_HOME%\lib\netty-codec-base-4.2.17.Final.jar;%APP_HOME%\lib\netty-transport-native-unix-common-4.2.17.Final.jar;%APP_HOME%\lib\netty-transport-4.2.17.Final.jar;%APP_HOME%\lib\netty-buffer-4.2.17.Final.jar;%APP_HOME%\lib\netty-resolver-4.2.17.Final.jar;%APP_HOME%\lib\netty-common-4.2.17.Final.jar;%APP_HOME%\lib\swagger-models-jakarta-2.2.52.jar;%APP_HOME%\lib\jackson-annotations-2.21.jar;%APP_HOME%\lib\commons-logging-1.3.6.jar;%APP_HOME%\lib\tomcat-embed-websocket-11.0.24.jar;%APP_HOME%\lib\tomcat-embed-core-11.0.24.jar;%APP_HOME%\lib\antlr4-runtime-4.13.2.jar;%APP_HOME%\lib\aspectjweaver-1.9.25.1.jar;%APP_HOME%\lib\jakarta.validation-api-3.1.1.jar;%APP_HOME%\lib\hibernate-models-1.1.1.jar;%APP_HOME%\lib\jboss-logging-3.6.3.Final.jar;%APP_HOME%\lib\classmate-1.7.3.jar;%APP_HOME%\lib\logback-core-1.5.38.jar;%APP_HOME%\lib\log4j-api-2.25.5.jar;%APP_HOME%\lib\jakarta.persistence-api-3.2.0.jar;%APP_HOME%\lib\byte-buddy-1.18.11.jar;%APP_HOME%\lib\jaxb-runtime-4.0.9.jar;%APP_HOME%\lib\jaxb-core-4.0.9.jar;%APP_HOME%\lib\jakarta.xml.bind-api-4.0.5.jar;%APP_HOME%\lib\jakarta.inject-api-2.0.1.jar;%APP_HOME%\lib\jakarta.transaction-api-2.0.1.jar;%APP_HOME%\lib\commons-lang3-3.20.0.jar;%APP_HOME%\lib\swagger-annotations-jakarta-2.2.52.jar;%APP_HOME%\lib\angus-activation-2.0.3.jar;%APP_HOME%\lib\jakarta.activation-api-2.1.4.jar;%APP_HOME%\lib\txw2-4.0.9.jar;%APP_HOME%\lib\istack-commons-runtime-4.1.2.jar


@rem Execute project-devops-deploy
@rem endlocal doesn't take effect until after the line is parsed and variables are expanded
@rem which allows us to clear the local environment before executing the java command
endlocal & "%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %PROJECT_DEVOPS_DEPLOY_OPTS%  -classpath "%CLASSPATH%" io.hexlet.project_devops_deploy.DemoApplication %* & call :exitWithErrorLevel

:exitWithErrorLevel
@rem Use "%COMSPEC%" /c exit to allow operators to work properly in scripts
"%COMSPEC%" /c exit %ERRORLEVEL%
