MAKEFLAGS += -j2
APP_NAME = loco_app

default: dev-frontend dev-backend
build: build-frontend build-backend
deps: deps-frontend deps-backend
start: start-docker-compose default

rtx:
	rtx install



### install dependecies
deps-frontend:
	cd frontend && bun install

deps-backend:
	cargo check


### dev server
dev-frontend:
	cd frontend && bun --bun run start

dev-backend:
	cargo loco start

start-docker-compose:
	docker compose up -d

stop-docker-compose:
	docker compose down

### build for prod
build-frontend:
	cd frontend && bun --bun run build

build-backend:
	cargo build --release

build-docker:

run-docker:
