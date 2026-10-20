test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build

#Docker локально
docker-build:
	sudo docker build -t app_full:latest .

docker-start:
	sudo docker run -p 8080:8080 -p 9090:9090 -e JAVA_OPTS="-Xms256m -Xmx512m -Dspring.profiles.active=dev" app_full
	

# деплой через ansible на удаленный сервер
full-deploy-dev:
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --ask-vault-pass

full-deploy-prod:
	ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -e "spring_profile=prod" --ask-vault-pass