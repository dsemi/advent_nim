SRC_FILES = $(shell find src/ -type f -name '*.nim')
C_FILES = $(shell find src/ -type f -name '*.')

BUILD_FLAGS = --threads:on -d:ssl

debug: BUILD_FLAGS += -d:debug
debug: main

release: BUILD_FLAGS += -d:release
release: main

danger: BUILD_FLAGS += -d:danger
danger: main

main: Makefile advent.nimble $(SRC_FILES) $(C_FILES) build_flags
	@nimble $(BUILD_FLAGS) build

.PHONY: force
build_flags: force
	@echo '$(BUILD_FLAGS)' | cmp -s - $@ || echo '$(BUILD_FLAGS)' > $@
