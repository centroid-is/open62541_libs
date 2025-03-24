# The Flutter tooling requires that developers have CMake 3.10 or later
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

# Download and build open62541
include(ExternalProject)
ExternalProject_Add(open62541
  URL "https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz"
  CMAKE_ARGS
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    -DUA_LOGLEVEL=100
    -DBUILD_SHARED_LIBS=ON
    -DUA_ENABLE_INLINABLE_EXPORT=ON
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
    -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake
    -DANDROID_ABI=${ANDROID_ABI}
    -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI}
    -DANDROID_NDK=${ANDROID_NDK}
    -DCMAKE_ANDROID_NDK=${ANDROID_NDK}
    -DANDROID_PLATFORM=${ANDROID_PLATFORM}
    -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}
    -DCMAKE_LIBRARY_OUTPUT_DIRECTORY=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
    -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
    -DCMAKE_SYSTEM_NAME=Android
  BUILD_IN_SOURCE 0
  INSTALL_COMMAND ""
)
ExternalProject_Get_Property(open62541 BINARY_DIR)


# Add the library as IMPORTED
add_library(open62541_import SHARED IMPORTED)
set_target_properties(open62541_import PROPERTIES
    IMPORTED_LOCATION "${BINARY_DIR}/bin/libopen62541.so"
)

# After getting BINARY_DIR
#message(FATAL_ERROR "BINARY_DIR: ${BINARY_DIR}")

set(open62541_libs_bundled_libraries
  "${BINARY_DIR}/bin/libopen62541.so"
) 