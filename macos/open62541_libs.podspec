#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint open62541_libs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'open62541_libs'
  # plugin version
  s.version          = '0.0.1'
  s.summary          = 'Open62541 library for macOS.'
  s.description      = 'OPC UA Open62541 library for macOS.'
  s.homepage         = 'https://github.com/open62541/open62541'
  s.license          = { :type => 'MPL-2.0', :text => 'Mozilla Public License Version 2.0' }
  s.author           = { 'Open62541' => 'https://github.com/open62541/open62541' }

  s.source = { 
    :http => 'https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz'
  }

  s.prepare_command = <<-CMD
  mkdir -p lib

  MBEDTLS_VERSION="mbedtls-3.6.3"
  echo "Building mbedtls..."
  curl -L https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/$MBEDTLS_VERSION.tar.gz -o mbedtls.tar.gz
  tar xzf mbedtls.tar.gz
  cd mbedtls-$MBEDTLS_VERSION
  cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
  cmake --build build
  cp build/library/libmbedtls.a ../lib/
  cp build/library/libmbedx509.a ../lib/
  cp build/library/libmbedcrypto.a ../lib/
  cd ..
  MBEDTLS_INCLUDE_DIRS=$(pwd)/mbedtls-$MBEDTLS_VERSION/build/include/
  MBEDTLS_LIBRARY=$(pwd)/lib/libmbedtls.a
  MBEDX509_LIBRARY=$(pwd)/lib/libmbedx509.a
  MBEDCRYPTO_LIBRARY=$(pwd)/lib/libmbedcrypto.a

  OPEN62541_VERSION="79e47f89837bc5e8f710d501e2afcd8ad71b0a28"
  echo "Building open62541 with mbedtls support..."
  curl -L https://github.com/open62541/open62541/archive/$OPEN62541_VERSION.tar.gz -o open62541.tar.gz
  tar xzf open62541.tar.gz
  cd open62541-$OPEN62541_VERSION
  cmake -B build -DUA_LOGLEVEL=100 -DBUILD_SHARED_LIBS=OFF -DUA_ENABLE_INLINABLE_EXPORT=ON -DCMAKE_BUILD_TYPE=Release -DUA_ENABLE_ENCRYPTION=MBEDTLS -DMBEDTLS_INCLUDE_DIRS=$MBEDTLS_INCLUDE_DIRS -DMBEDTLS_LIBRARY=$MBEDTLS_LIBRARY -DMBEDX509_LIBRARY=$MBEDX509_LIBRARY -DMBEDCRYPTO_LIBRARY=$MBEDCRYPTO_LIBRARY -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64"
  cmake --build build
  cp build/bin/libopen62541.a ../lib/
CMD
  s.vendored_libraries = [ 'lib/libopen62541.a', 'lib/libmbedtls.a', 'lib/libmbedx509.a', 'lib/libmbedcrypto.a' ]
  s.preserve_paths = [ 'open62541-$OPEN62541_VERSION/**/*', 'mbedtls-$MBEDTLS_VERSION/**/*' ]
  s.static_framework = true

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.user_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '"${PODS_ROOT}/../Flutter/ephemeral/.symlinks/plugins/open62541_libs/macos/lib"',
    'OTHER_LDFLAGS' => '-force_load "${PODS_ROOT}/../Flutter/ephemeral/.symlinks/plugins/open62541_libs/macos/lib/libopen62541.a"'
  }

  s.swift_version = '5.0'
end
