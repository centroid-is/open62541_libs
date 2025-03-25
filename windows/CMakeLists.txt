# The Flutter tooling requires that developers have CMake 3.10 or later
cmake_minimum_required(VERSION 3.10)

# # Manipulate BINARY_NAME within this file
# cmake_policy(SET CMP0079 NEW)

# Project-level configuration.
set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

# # Global configuration
# set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "")
# set(CMAKE_INTERPROCEDURAL_OPTIMIZATION OFF CACHE INTERNAL "")
# # A BIG TODO this is not great, but windows is not our primary target
# set(MY_BUILD_TYPE "Debug" CACHE STRING "" FORCE)

# # Configure open62541 build options
# set(UA_ENABLE_DEBUG_SANITIZER OFF CACHE BOOL "Disable sanitizers" FORCE)
# set(UA_LOGLEVEL 100 CACHE INTERNAL "")
# set(UA_ENABLE_ENCRYPTION "MBEDTLS" CACHE STRING "" FORCE)
# set(UA_ENABLE_INLINABLE_EXPORT ON CACHE INTERNAL "")

# Use FetchContent
include(FetchContent)

# set(MBEDTLS_FATAL_WARNINGS OFF)
# set(ENABLE_TESTING OFF CACHE BOOL "Disable mbedTLS tests" FORCE)
# set(ENABLE_PROGRAMS OFF CACHE BOOL "Disable mbedTLS programs" FORCE)
# set(USE_STATIC_MBEDTLS_LIBRARY ON)

FetchContent_Declare(
  mbedtls
  GIT_REPOSITORY https://github.com/Mbed-TLS/mbedtls.git
  GIT_TAG v3.6.2
  GIT_SUBMODULES framework  # Enable submodule fetch
)

FetchContent_MakeAvailable(mbedtls)

# set(MBEDTLS_INCLUDE_DIRS ${mbedtls_SOURCE_DIR}/include)
# set(MBEDTLS_LIBRARY ${mbedtls_BINARY_DIR}/library/${MY_BUILD_TYPE}/mbedtls.lib)
# set(MBEDX509_LIBRARY ${mbedtls_BINARY_DIR}/library/${MY_BUILD_TYPE}/mbedx509.lib)
# set(MBEDCRYPTO_LIBRARY ${mbedtls_BINARY_DIR}/library/${MY_BUILD_TYPE}/mbedcrypto.lib)
# # Declare open62541 after mbedTLS
# FetchContent_Declare(
#   open62541
#   URL https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz
# )

# # Make the content available
# FetchContent_MakeAvailable(open62541)

# target_link_libraries(${BINARY_NAME} PRIVATE
#   ${MBEDTLS_LIBRARY}
#   ${MBEDX509_LIBRARY}
#   ${MBEDCRYPTO_LIBRARY}
#   open62541
# )

# add_dependencies(${BINARY_NAME} open62541)
# target_link_libraries(${BINARY_NAME} PRIVATE
#   ws2_32
#   iphlpapi
# )
# target_link_options(${BINARY_NAME} PRIVATE "/WHOLEARCHIVE:${CMAKE_BINARY_DIR}/bin/${MY_BUILD_TYPE}/open62541.lib")
