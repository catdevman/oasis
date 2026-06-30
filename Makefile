PHONY: build clean

build: clean
	go build -o oasis ./main.go

plugin-build:
	go build -o ./plugins/common ./plugin/common

db-up:
	docker compose up -d db

db-down:
	docker compose down

db-seed:
	cd command/generate && go run main.go

all: build plugin-build

clean:
	rm -rf oasis
