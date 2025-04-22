BUILD_DIR := build
TEST_TARGET := tests

CMAKE_FLAGS := 
MAKE_FLAGS := -j $(shell nproc || sysctl -n hw.logicalcpu)

.PHONY: configure
configure:
	cmake -S . -B $(BUILD_DIR) $(CMAKE_FLAGS)

.PHONY: build
build: configure
	cmake --build $(BUILD_DIR) -- $(MAKE_FLAGS)

.PHONY: test
test: build
	./$(BUILD_DIR)/$(TEST_TARGET)

.PHONY: tidy
tidy:
	@if [ -z "$(CI)" ]; then \
		find . -iname '*.h' -o -iname '*.cpp' \
		-o -path ./$(BUILD_DIR) -prune -false \
		-o -path ./test -prune -false \
		| xargs clang-tidy -p ./$(BUILD_DIR) -warnings-as-errors='*'; \
	else \
		find . -iname '*.h' -o -iname '*.cpp' \
		-o -path ./$(BUILD_DIR) -prune -false \
		-o -path ./test -prune -false \
		| xargs clang-tidy -p ./$(BUILD_DIR); \
	fi

