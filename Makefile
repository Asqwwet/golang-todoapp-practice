include .env
export


export PROJECT_ROOT=$(shell pwd)

env-up: 
	@docker compose up -d todoapp-postgres

env-down:
	@docker compose down  todoapp-postgres


post-forwarder-open:
	@docker compose up -d post-forwarder

post-forwarder-close:
	@docker compose down post-forwarder

env-cleanup:
	@read -p "Are you sure that you want to delete all the data? (Y/N): " ans; \
	if [ "$$ans" = "Y" ]; then \
		docker compose down todoapp-postgres && \
		rm -rf out/pgdata && \
		echo "Files are removed"; \
	else \
		echo "Cleanup environment are cancelled"; \
	fi


migrate-create:
	@if [ -z "$(seq)" ]; then \
		echo "Отсуствует нужный параметр при вводе"; \
		exit 1 ; \
	fi; \
	docker compose run --rm  todoapp-postgres-migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"


migrate-up:
	@make migrate-action action=up

migrate-down:
	@make migrate-action action=down

migrate-action:
	@if [-z "$(action)"]; then \
		echo "Entered no correct paramets"; \
		exit 1; \
	fi; \
	docker compose run --rm todoapp-postgres-migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@todoapp-postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"
		