#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint open62541_libs.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'open62541_libs'
  s.version          = '0.0.1'
  s.summary          = 'Open62541 library for macOS.'
  s.description      = <<-DESC
Open62541 library for macOS awesome right.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MPL-2.0', :text => 'Mozilla Public License Version 2.0' }
  s.author           = { 'Your Company' => 'email@example.com' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.source = { 
    :http => 'https://github.com/open62541/open62541/archive/refs/tags/v1.4.11.1.tar.gz'
  }

  s.prepare_command = <<-CMD
    pwd
    ls -la
    curl -L https://github.com/open62541/open62541/archive/refs/tags/v1.4.11.1.tar.gz -o open62541.tar.gz
    tar xzf open62541.tar.gz
    cd open62541-1.4.11.1
    cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release
    cmake --build build
    cp build/bin/libopen62541.a ../../lib/
  CMD
  #s.source           = { :path => '.' }
  s.vendored_libraries = 'lib/libopen62541.a'
  s.preserve_paths = 'open62541-1.4.11.1/**/*'
  s.static_framework = true

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'open62541_libs_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.13'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  s.user_target_xcconfig = {
    'LIBRARY_SEARCH_PATHS' => '"${PODS_ROOT}/../Flutter/ephemeral/.symlinks/plugins/open62541_libs/macos/lib"',
    'OTHER_LDFLAGS' => '-force_load "${PODS_ROOT}/../Flutter/ephemeral/.symlinks/plugins/open62541_libs/macos/lib/libopen62541.a"'
  }

  s.swift_version = '5.0'
end
