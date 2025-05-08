# The Flutter tooling requires that developers have CMake 3.10 or later
cmake_minimum_required(VERSION 3.10)

# Manipulate BINARY_NAME within this file
cmake_policy(SET CMP0079 NEW)

# Project-level configuration.
set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

# Global configuration
set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "")
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE INTERNAL "")

# Configure open62541 build options
set(UA_ENABLE_DEBUG_SANITIZER OFF CACHE BOOL "Disable sanitizers" FORCE)
set(UA_LOGLEVEL 100 CACHE INTERNAL "")
set(UA_ENABLE_ENCRYPTION "MBEDTLS" CACHE STRING "" FORCE)
set(UA_ENABLE_INLINABLE_EXPORT ON CACHE INTERNAL "")

# Use FetchContent
include(FetchContent)

set(MBEDTLS_FATAL_WARNINGS OFF)
set(ENABLE_TESTING OFF CACHE BOOL "Disable mbedTLS tests" FORCE)
set(ENABLE_PROGRAMS OFF CACHE BOOL "Disable mbedTLS programs" FORCE)
set(USE_STATIC_MBEDTLS_LIBRARY ON)

FetchContent_Declare(
  mbedtls
  URL https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/mbedtls-3.6.3.tar.gz
)
# There is some weird thing with mbedtls that causes it to fail on Debug builds. 
# The first time it is built.
add_compile_options($<$<CONFIG:Debug>:-O1>)
add_compile_options(-w) # Ignore warnings from mbedtls. Macro redefinition warnings. We don't care about them.

FetchContent_MakeAvailable(mbedtls)

set(MBEDTLS_INCLUDE_DIRS ${mbedtls_SOURCE_DIR}/include)
set(MBEDTLS_LIBRARY ${mbedtls_BINARY_DIR}/library/libmbedtls.a)
set(MBEDX509_LIBRARY ${mbedtls_BINARY_DIR}/library/libmbedx509.a)
set(MBEDCRYPTO_LIBRARY ${mbedtls_BINARY_DIR}/library/libmbedcrypto.a)

# Declare open62541 after mbedTLS
FetchContent_Declare(
  open62541
  URL https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz
)

# Make the content available
FetchContent_MakeAvailable(open62541)

target_link_libraries(${BINARY_NAME} PRIVATE
  ${MBEDTLS_LIBRARY}
  ${MBEDX509_LIBRARY}
  ${MBEDCRYPTO_LIBRARY}
  open62541
)

add_dependencies(${BINARY_NAME} open62541)
# Include all symbols from the open62541 library
target_link_options(${BINARY_NAME} PRIVATE 
  "-Wl,--whole-archive" 
  "${CMAKE_BINARY_DIR}/bin/libopen62541.a"
  "-Wl,--no-whole-archive"
)

# Add the -rdynamic flag to export all symbols of the executable / open62541 library
set_target_properties(${BINARY_NAME} PROPERTIES
  ENABLE_EXPORTS ON
  LINK_FLAGS "-rdynamic"
)
