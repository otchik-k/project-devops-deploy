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
	

#Ansible	
configure-remote-srv:
	ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
	
configure-remote-srv-vvv:
	ansible-playbook -i inventory.ini playbook.yml -vvv --ask-vault-pass

postgres-deploy:
	ansible-playbook -i inventory.ini postgresql.yml --ask-vault-pass
	
postgres-deploy-vvv:
	ansible-playbook -i inventory.ini postgresql.yml --ask-vault-pass -vvv

deploy-app:
	ansible-playbook -i inventory.ini deploy.yml --ask-vault-pass

deploy-app-vvv:
	ansible-playbook -i inventory.ini deploy.yml -vvv --ask-vault-pass

	
full-deploy-dev:
	ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass

full-deploy-prod:
	ansible-playbook -i inventory.ini playbook.yml -e "spring_profile=prod" --ask-vault-pass