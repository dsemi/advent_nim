SRC_FILES = $(shell find src/ -type f -name '*.nim')
C_FILES = $(shell find src/ -type f -name '*.')

main: Makefile advent.nimble $(SRC_FILES) $(C_FILES)
	@nimble --threads:on -d:release -d:ssl build
