.PHONY: run
run: migrate
	docker-compose up

.PHONY: migrate
migrate:
	docker-compose run --rm app rails db:create
	docker-compose run --rm app rails db:migrate
	docker-compose run --rm app bash -c "RACK_ENV=test rails db:migrate"

.PHONY: rollback
rollback:
	docker-compose run --rm app rails db:rollback
	docker-compose run --rm app bash -c "RACK_ENV=test rails db:rollback"

.PHONY: console
console:
	docker-compose run --rm app rails console

.PHONY: bundle-update
bundle-update:
	docker-compose run --rm app bundle update

.PHONY: bundle
bundle:
	docker-compose run --rm app bundle
