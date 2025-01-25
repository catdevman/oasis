PHONY: build clean

build: clean
	go build -o oasis ./main.go

plugin-build:
	go build -o ./plugin/greeter ./plugin/plugin.go
	chmod a+rwx ./plugin/greeter

all: build plugin-build

clean:
	rm -rf oasis
