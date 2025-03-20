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
  # TODO: wait for this PR to be merged: https://github.com/open62541/open62541/pull/7177
  URL https://github.com/centroid-is/open62541/archive/50fe223c55c8eafe4937e50104cab35a1514a3a0.tar.gz
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/open62541"
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=Release
    -DUA_LOGLEVEL=100
    -DBUILD_SHARED_LIBS=OFF
    -DUA_ENABLE_INLINABLE_EXPORT=ON
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
  BUILD_IN_SOURCE 0
  INSTALL_COMMAND ""
)

# Get the build directory for the external project
ExternalProject_Get_Property(open62541 BINARY_DIR)

if(WIN32)
  set(RELEASE_LIB "${BINARY_DIR}/bin/Release/open62541.lib")
  set(DEBUG_LIB "${BINARY_DIR}/bin/Debug/open62541.lib")
  # A BIG TODO, I dont know how to determine which library is used
  # The release argument above is not used for some reason
  set(open62541_libs_bundled_libraries
    "${DEBUG_LIB}"
    PARENT_SCOPE
  )
else()
  set(open62541_libs_bundled_libraries
    "${BINARY_DIR}/bin/libopen62541.a"
    PARENT_SCOPE
  )
endif()
