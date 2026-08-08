IMAGE_NAME      ?= sword-of-ianna-builder
DOCKER_PLATFORM ?= linux/amd64
BUILD_DIR       := build
SRC_DIR         := src

ARTIFACTS := SwordOfIanna.tap SwordOfIanna_Full.tap \
             ianna-3dos.dsk ianna-sidea.dsk ianna-sideb.dsk \
             sword.hdf ianna-cart.rom ianna-dan.rom ianna-if2.rom

.PHONY: all build image collect clean

all: build

image:
	docker build --platform $(DOCKER_PLATFORM) --build-arg TARGETPLATFORM=$(DOCKER_PLATFORM) -t $(IMAGE_NAME) .

build: image
	docker run --rm --platform $(DOCKER_PLATFORM) --entrypoint /bin/bash \
		-v $(CURDIR):/src $(IMAGE_NAME) \
		-c 'ln -sf /usr/local/bin/gentap /src/src/gentap && cd /src/src && make all'
	$(MAKE) collect

collect:
	mkdir -p $(BUILD_DIR)
	for f in $(ARTIFACTS); do \
		[ -f $(SRC_DIR)/$$f ] && cp $(SRC_DIR)/$$f $(BUILD_DIR)/; \
	done
	[ -d $(SRC_DIR)/iannasd ] && cp -R $(SRC_DIR)/iannasd $(BUILD_DIR)/

clean:
	rm -rf $(BUILD_DIR)
