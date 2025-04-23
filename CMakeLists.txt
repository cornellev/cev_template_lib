cmake_minimum_required(VERSION 3.14)
project(Template LANGUAGES CXX)

set(PROJECT_VERSION 0.0.0)
string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWER)

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

# Lib
add_library(${PROJECT_NAME_LOWER} lib/lib.cpp)
add_library(CEV::${PROJECT_NAME} ALIAS ${PROJECT_NAME_LOWER})
# https://stackoverflow.com/questions/25676277/cmake-target-include-directories-prints-an-error-when-i-try-to-add-the-source
target_include_directories(${PROJECT_NAME_LOWER} PUBLIC  
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>  
  $<INSTALL_INTERFACE:include>
)

# Tests
if(${CMAKE_PROJECT_NAME} STREQUAL ${PROJECT_NAME})
  # https://stackoverflow.com/questions/42118956/add-subdirectory-without-installing-anything
  add_subdirectory(test/doctest EXCLUDE_FROM_ALL)
  add_executable(tests test/test.cpp)
  target_link_libraries(tests ${PROJECT_NAME_LOWER} doctest)
endif()

# Install
include(CMakePackageConfigHelpers)
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME_LOWER})

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION ${INSTALL_CONFIGDIR}
)

# Generate the version CMake file
write_basic_package_version_file(
  ${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY AnyNewerVersion
)

export(TARGETS ${PROJECT_NAME_LOWER} NAMESPACE CEV FILE ${PROJECT_NAME}Targets.cmake)
export(PACKAGE ${PROJECT_NAME})

# Install the targets and export them
install(EXPORT ${PROJECT_NAME}Targets
  NAMESPACE CEV::
  DESTINATION ${INSTALL_CONFIGDIR}
)

install(TARGETS ${PROJECT_NAME_LOWER}
  EXPORT ${PROJECT_NAME}Targets
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# Install headers
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME_LOWER}
  FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp"
)

# Install configuration files
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION ${INSTALL_CONFIGDIR}
)

# Per https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#can-i-do-make-uninstall-with-cmake
# uninstall target
if(NOT TARGET uninstall)
  configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake_uninstall.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
    IMMEDIATE @ONLY)

  add_custom_target(uninstall
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()
