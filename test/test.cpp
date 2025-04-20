#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"
#include "lib.h"

TEST_CASE("testing the factorial function") {
    CHECK(cpp_template::add(1, 2) == 3);
}
