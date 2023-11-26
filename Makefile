include .env
-include .env.local
export

UID ?= $(shell id -u)

.SILENT:

.PHONY: build

all: build install patch-vcard run

build:
	docker buildx build -t $(IMAGE) --build-arg BASE_IMAGE_VERSION=$(BASE_IMAGE_VERSION) --build-arg USER_ID=$(UID) .

install:
	docker run --rm -ti $(MOUNTS) $(IMAGE) bundle install --no-cache

patch-vcard:
	docker run --rm -ti --entrypoint /bin/bash $(MOUNTS) $(IMAGE) ./patch-vcard.sh

run:
	docker run --rm -ti $(MOUNTS) $(IMAGE)

shell:
	docker run --rm -ti $(MOUNTS) -u 0 $(IMAGE) bash