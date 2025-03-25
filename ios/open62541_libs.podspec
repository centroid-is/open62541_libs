Pod::Spec.new do |s|
  s.name             = 'open62541_libs'
  s.version          = '0.0.1'
  s.summary          = 'Open62541 library for iOS'
  s.description      = <<-DESC
  Open62541 library for iOS.
  DESC
  s.homepage         = 'https://github.com/open62541/open62541'
  s.license          = { :type => 'MPL-2.0', :text => 'Mozilla Public License Version 2.0' }
  s.author           = { 'Open62541' => 'https://github.com/open62541/open62541' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
  
  s.prepare_command = <<-CMD
    curl -L https://github.com/open62541/open62541/archive/79e47f89837bc5e8f710d501e2afcd8ad71b0a28.tar.gz -o open62541.tar.gz
    tar xzf open62541.tar.gz
    cd open62541-79e47f89837bc5e8f710d501e2afcd8ad71b0a28
    cmake -B build -DUA_LOGLEVEL=100 -DBUILD_SHARED_LIBS=OFF -DUA_ENABLE_INLINABLE_EXPORT=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT=iphoneos -DCMAKE_OSX_ARCHITECTURES=arm64
    cmake --build build
    mkdir -p ../lib
    cp build/bin/libopen62541.a ../lib/
  CMD
  
  s.vendored_libraries = 'lib/libopen62541.a'
  
  s.user_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '"${PODS_ROOT}/../.symlinks/plugins/open62541_libs/ios/lib"',
    'OTHER_LDFLAGS' => '-force_load "${PODS_ROOT}/../.symlinks/plugins/open62541_libs/ios/lib/libopen62541.a"'
  }
end
