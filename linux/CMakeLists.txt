# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

# Download and build open62541
include(ExternalProject)
ExternalProject_Add(open62541
  URL https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=Release
    -DUA_LOGLEVEL=100
    -DBUILD_SHARED_LIBS=OFF
    -DUA_ENABLE_INLINABLE_EXPORT=ON
  BUILD_IN_SOURCE 0
  INSTALL_COMMAND ""
)

# Get the build directory for the external project
ExternalProject_Get_Property(open62541 BINARY_DIR)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(open62541_libs_bundled_libraries
  "${BINARY_DIR}/bin/libopen62541.a"
  PARENT_SCOPE
)