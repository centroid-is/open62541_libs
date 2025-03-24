# The Flutter tooling requires that developers have CMake 3.10 or later
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

# Disable sanitizers
set(UA_ENABLE_DEBUG_SANITIZER OFF CACHE BOOL "Disable sanitizers" FORCE)
# Configure open62541 build options
set(UA_LOGLEVEL 100 CACHE INTERNAL "")
set(BUILD_SHARED_LIBS ON CACHE INTERNAL "")
set(UA_ENABLE_INLINABLE_EXPORT ON CACHE INTERNAL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE INTERNAL "")

# Use FetchContent
include(FetchContent)
FetchContent_Declare(
    open62541
    URL https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz
)

# Make the content available
FetchContent_MakeAvailable(open62541)

# Set Android-specific properties for the open62541 target
set_target_properties(open62541 PROPERTIES
    ANDROID_NDK ${ANDROID_NDK}
    ANDROID_ABI ${ANDROID_ABI}
    ANDROID_PLATFORM ${ANDROID_PLATFORM}
)

# Set the output path for the library
set(open62541_libs_bundled_libraries
    ${CMAKE_CURRENT_BINARY_DIR}/_deps/open62541-build/bin/libopen62541.so
)