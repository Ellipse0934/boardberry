PROJECTNAME := $(shell basename $(shell pwd))

BUILDDIR =
SOURCEDIR := src
SCSOURCES := $(shell echo `find . -type f -path "./**/$(PROJECTNAME)/*.cpp"` | cut -c 3-)
OBJECTS = $(foreach SCSOURCE,$(SCSOURCES),$(addprefix $(BUILDDIR)/,$(shell basename $(SCSOURCE:%.cpp=%.o))))
BINARY = $(addprefix $(BUILDDIR)/,$(PROJECTNAME))
HEADERDIR := $(SOURCEDIR)/
BINARYSOURCES := $(shell find . -type f -name "*.cpp" -not -path "./**/$(PROJECTNAME)**/*.cpp")
TESTSSOURCE := $(shell find . -type f -path "./**/$(PROJECTNAME)-tests/*.cpp")

NULLPIPE =

RELEASE ?=false
AGGRESSIVE_OPTIMIZE ?=false

CFLAGS = -Wall -Wextra -Werror -std=c++20

CC_NAME =

ifneq ($(shell echo | $(CXX) -dM -E - | grep "__clang__"),)
	CC_NAME =clang
else
	ifneq ($(shell echo | $(CXX) -dM -E - | grep "__GNUC__"),)
		CC_NAME =gnu
	else
		$(error EITHER CLANG OR GCC IS REQUIRED TO COMPILE $(PROJECTNAME))
	endif
endif

ifeq ($(RELEASE),false)
	CFLAGS += -g -Og
	BUILDDIR = build/debug
else
	BUILDDIR += build/release
	CFLAGS += -flto

	ifneq ($(CC_NAME),clang)
		CFLAGS += -s
	endif

	ifeq ($(AGGRESSIVE_OPTIMIZE),true)
		CFLAGS += -Ofast -mtune=native -march=native
		ifeq ($(CC_NAME),gnu)
			CFLAGS += -fmodulo-sched -fmodulo-sched-allow-regmoves \
				      -fgcse-las -fdevirtualize-speculatively -fira-hoist-pressure \
					  -floop-parallelize-all -ftree-parallelize-loops=4
		endif
	else
		CFLAGS += -O3
	endif
endif

ifneq ($(OS),Windows_NT)
	UNAME_S := $(shell uname -s)

	ifneq ($(UNAME_S),Darwin)
		CFLAGS += -static
	endif

	NULLPIPE = /dev/null
else
	NULLPIPE = NUL
endif

main: init $(BINARY)

$(BINARY): $(BINARYSOURCES) libboardberry.a
	$(CXX) $(CFLAGS) $(BINARYSOURCES) -I$(HEADERDIR) -L$(BUILDDIR) -lboardberry -o $@

$(OBJECTS): $(SCSOURCES)
	$(foreach SCSOURCE,$(SCSOURCES),`$(CXX) $(CFLAGS) -fPIE -I$(HEADERDIR) -c $(SCSOURCE) -o $(addprefix $(BUILDDIR)/,$(shell basename $(SCSOURCE:%.cpp=%.o)))`)

libboardberry.a: $(OBJECTS)
	ar -crs $(BUILDDIR)/libboardberry.a $(OBJECTS)

.PHONY: init
init:
	@-mkdir -p $(BUILDDIR) 2> $(NULLPIPE)

.PHONY: clean
clean:
	@-rm -fdr build/*

make-tests-out-dir:
	-mkdir $(BUILDDIR)/tests

.PHONY: compile-tests
compile-tests: main make-tests-out-dir
	$(foreach TESTSOURCE,$(TESTSSOURCE),`$(CXX) $(CFLAGS) -I$(HEADERDIR) -L$(BUILDDIR) -l$(PROJECTNAME) $(TESTSOURCE) -o $(addprefix $(BUILDDIR)/tests/,$(shell basename $(TESTSOURCE:%.cpp=%)))`)

.PHONY: test
test: compile-tests
	./test.sh $(BUILDDIR)/tests

.PHONY: help
help:
# TODO(#9): implement help for the makefile
	$(error TODO implement help for the makefile)
