#pragma once

#define MAJOR 0
#define MINOR 0
#define PATCH 2

#include <cstdio>

int print_version() {
    return printf("BoardBerry %d.%d.%d\n", MAJOR, MINOR, PATCH);
}
