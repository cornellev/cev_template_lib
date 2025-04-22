cmake_minimum_required(VERSION 3.14)
project(cev_template_lib LANGUAGES CXX)

set(PROJECT_VERSION 0.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(USE_SANITIZERS "Compile with ASan and UBSan" OFF)
if(DEFINED ENV{CI})
  set(USE_SANITIZERS ON)
  set(CMAKE_COMPILE_WARNING_AS_ERROR ON)
endif()

add_compile_options(-Wall -Wextra -g)
if(USE_SANITIZERS) 
  message(STATUS "Using address and UB sanitizers")
  add_compile_options(-fsanitize=address,undefined)
  add_link_options(-fsanitize=address,undefined)
endif()

add_library(${PROJECT_NAME} lib/lib.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC include)

if(${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
  add_subdirectory(test/doctest)
  add_executable(tests test/test.cpp)
  target_link_libraries(tests ${PROJECT_NAME} doctest)
endif()
