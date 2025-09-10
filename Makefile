PHONY: build clean

build: clean
	go build -o oasis ./main.go

plugin-build:
	go build -o ./plugins/common ./plugin/common.go

all: build plugin-build

clean:
	rm -rf oasis
