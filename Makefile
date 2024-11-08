PHONY: build clean

build: clean
	go build -o oasis ./cmd/oasis

clean:
	rm -rf oasis
