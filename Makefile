PHONY: build clean

build: clean
	go build -o oasis ./main.go

clean:
	rm -rf oasis
