.PHONY: build publish test local-test clean docker-start docker-clean docker-stop

build:
	./scripts/build.sh

publish:
	./scripts/publish.sh

clean:
	./scripts/clean.sh

docker-start:
	./scripts/docker-start.sh

docker-stop:
	./scripts/docker-stop.sh

docker-clean:
	./scripts/docker-clean.sh
