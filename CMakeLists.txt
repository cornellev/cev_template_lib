cmake_minimum_required(VERSION 3.14)
project(cpp_template LANGUAGES CXX)

set(PROJECT_VERSION 0.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_compile_options(-Wall -Wextra -g)
if(DEFINED ENV{CI}) 
  message(WARNING "hi")
  add_compile_options(-fsanitize=address,undefined)
  add_link_options(-fsanitize=address,undefined)
endif()

add_library(${PROJECT_NAME} lib/lib.cpp)
target_include_directories(${PROJECT_NAME} PUBLIC include)

if(${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
  add_subdirectory(doctest)
  add_executable(tests test/test.cpp)
  target_link_libraries(tests ${PROJECT_NAME} doctest)
endif()
