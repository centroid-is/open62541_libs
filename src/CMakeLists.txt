# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(open62541_libs_library VERSION 0.0.1 LANGUAGES C)

include(FetchContent)

FetchContent_Declare(
    open62541
    URL https://github.com/open62541/open62541/archive/refs/tags/v1.4.11.1.tar.gz
)

FetchContent_MakeAvailable(open62541


message(FATAL_ERROR "open62541 source dir: ${open62541_SOURCE_DIR}"
message(FATAL_ERROR "open62541 binary dir: ${open62541_BINARY_DIR}")

add_library(open62541_libs SHARED
  "open62541_libs.c"
)

set_target_properties(open62541_libs PROPERTIES
  PUBLIC_HEADER open62541_libs.h
  OUTPUT_NAME "open62541_libs"
)

target_compile_definitions(open62541_libs PUBLIC DART_SHARED_LIB)
target_link_libraries(open62541_libs PRIVATE open62541)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(open62541_libs PRIVATE "-Wl,-z,max-page-size=16384")
endif()
