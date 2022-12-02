SRC_FILES = $(shell find src/ -type f -name '*.nim')

main: Makefile advent.nimble $(SRC_FILES)
	@nimble --threads:on -d:release -d:ssl build
