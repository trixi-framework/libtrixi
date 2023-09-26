PROJECT_DIR ?= ../../libtrixi-julia
PREFIX ?= build

all:
	julia --project=. build.jl $(PROJECT_DIR) $(PREFIX)

clean:
	rm -rf $(PREFIX)

.PHONY: all clean
