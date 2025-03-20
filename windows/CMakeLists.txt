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
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
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
  set(RELEASE_LIB "${BINARY_DIR}/open62541-object.dir/Release/open62541-object.lib")
  set(DEBUG_LIB "${BINARY_DIR}/open62541-object.dir/Debug/open62541-object.lib")
  
  if(EXISTS "${RELEASE_LIB}")
    set(open62541_libs_bundled_libraries "${RELEASE_LIB}" PARENT_SCOPE)
  else()
    set(open62541_libs_bundled_libraries "${DEBUG_LIB}" PARENT_SCOPE)
  endif()
else()
  set(open62541_libs_bundled_libraries
    "${BINARY_DIR}/bin/libopen62541.a"
    PARENT_SCOPE
  )
endif()
