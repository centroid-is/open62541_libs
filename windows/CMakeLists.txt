# The Flutter tooling requires that developers have CMake 3.10 or later
cmake_minimum_required(VERSION 3.10)

# Manipulate BINARY_NAME within this file
cmake_policy(SET CMP0079 NEW)

set(PROJECT_NAME "open62541_libs")
project(${PROJECT_NAME} LANGUAGES C)

include(ExternalProject)

ExternalProject_Add(mbedtls
  URL https://github.com/ARMmbed/mbedtls/archive/refs/tags/v3.6.3.zip
  CMAKE_ARGS 
    -DMBEDTLS_FATAL_WARNINGS=OFF
    -DENABLE_TESTING=OFF
    -DENABLE_PROGRAMS=OFF
    -DUSE_STATIC_MBEDTLS_LIBRARY=ON
    -DBUILD_SHARED_LIBS=OFF
    -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/mbedtls
    -DCMAKE_BUILD_TYPE=Release
)

set(MBEDTLS_INCLUDE_DIRS ${CMAKE_BINARY_DIR}/mbedtls/include)
set(MBEDTLS_LIBRARY ${CMAKE_BINARY_DIR}/mbedtls/lib/mbedtls.lib)
set(MBEDX509_LIBRARY ${CMAKE_BINARY_DIR}/mbedtls/lib/mbedx509.lib)
set(MBEDCRYPTO_LIBRARY ${CMAKE_BINARY_DIR}/mbedtls/lib/mbedcrypto.lib)

ExternalProject_Add(open62541
  URL https://github.com/centroid-is/open62541/archive/50fe223c55c8eafe4937e50104cab35a1514a3a0.tar.gz
  CMAKE_ARGS 
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
    -DBUILD_SHARED_LIBS=OFF
    -DUA_ENABLE_DEBUG_SANITIZER=OFF
    -DUA_LOGLEVEL=100
    -DUA_ENABLE_ENCRYPTION=MBEDTLS
    -DUA_ENABLE_INLINABLE_EXPORT=ON
    -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/open62541
    -DCMAKE_BUILD_TYPE=Release
    -DMBEDTLS_INCLUDE_DIRS=${MBEDTLS_INCLUDE_DIRS}
    -DMBEDTLS_LIBRARY=${MBEDTLS_LIBRARY}
    -DMBEDX509_LIBRARY=${MBEDX509_LIBRARY}
    -DMBEDCRYPTO_LIBRARY=${MBEDCRYPTO_LIBRARY}
)

target_link_libraries(${BINARY_NAME} PRIVATE
  ${MBEDTLS_LIBRARY}
  ${MBEDX509_LIBRARY}
  ${MBEDCRYPTO_LIBRARY}
  ${CMAKE_BINARY_DIR}/open62541/lib/open62541.lib
)

add_dependencies(${BINARY_NAME} open62541)
target_link_libraries(${BINARY_NAME} PRIVATE
  ws2_32
  iphlpapi
  bcrypt
)
target_link_options(${BINARY_NAME} PRIVATE "/WHOLEARCHIVE:${CMAKE_BINARY_DIR}/open62541/lib/open62541.lib")
