SRC_FILES = $(shell find src/ -type f -name '*.nim')

main: advent.nimble $(SRC_FILES)
	@nimble --threads:on -d:release -d:ssl build
