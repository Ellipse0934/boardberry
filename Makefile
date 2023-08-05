PROJECTNAME := $(shell basename $(shell pwd))

SOURCEDIR := src
BUILDDIR =
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

	NULLPIPE = /dev/null
else
	NULLPIPE = NUL
endif

build: init $(BINARY)

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
	$(foreach TESTSOURCE,$(TESTSSOURCE),`$(CXX) $(CFLAGS) $(TESTSOURCE) -I$(HEADERDIR) -L$(BUILDDIR) -l$(PROJECTNAME) -o $(addprefix $(BUILDDIR)/tests/,$(shell basename $(TESTSOURCE:%.cpp=%)))`)

.PHONY: test
test: compile-tests
	./test.sh $(BUILDDIR)/tests

SEPERATOR = "--------------------"

.PHONY: help
help:
	@-echo $(SEPERATOR)
	@-echo "Available subcommands:"
	@-echo -e "\tbuild: Builds the project"
	@-echo -e "\ttest:   Builds and tests the project"
	@-echo $(SEPERATOR)
	@-echo "Available options:"
	@-echo -e "RELEASE=(true | false):\n\t\tIf true, compiles in release mode, with optimizations,"
	@-echo -e "\t\tif false compiles in debug mode, with debug info and minimal optimizations.\n\t\tdefault: false"
	@-echo -e "AGGRESSIVE_OPTIMIZE=(true | false):\n\t\tIf true, compiles with \`-Ofast -mtune=native -march=native\`,"
	@-echo -e "\t\t!!!Only effective with RELEASE being true!!!. default: false"
	@-echo $(SEPERATOR)
