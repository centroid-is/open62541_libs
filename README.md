# open62541_libs

A new Flutter FFI plugin project.

## Getting Started

This project is a starting point for a Flutter
[FFI plugin](https://flutter.dev/to/ffi-package),
a specialized package that includes native code directly invoked with Dart FFI.

## Project structure

This template uses the following structure:

* `src`: Contains the native source code, and a CmakeFile.txt file for building
  that source code into a dynamic library.

* `lib`: Contains the Dart code that defines the API of the plugin, and which
  calls into the native code using `dart:ffi`.

* platform folders (`android`, `ios`, `windows`, etc.): Contains the build files
  for building and bundling the native code library with the platform application.

## Building and bundling native code

The `pubspec.yaml` specifies FFI plugins as follows:

```yaml
  plugin:
    platforms:
      some_platform:
        ffiPlugin: true
```

This configuration invokes the native build for the various target platforms
and bundles the binaries in Flutter applications using these FFI plugins.

This can be combined with dartPluginClass, such as when FFI is used for the
implementation of one platform in a federated plugin:

```yaml
  plugin:
    implements: some_other_plugin
    platforms:
      some_platform:
        dartPluginClass: SomeClass
        ffiPlugin: true
```

A plugin can have both FFI and method channels:

```yaml
  plugin:
    platforms:
      some_platform:
        pluginClass: SomeName
        ffiPlugin: true
```

The native build systems that are invoked by FFI (and method channel) plugins are:

* For Android: Gradle, which invokes the Android NDK for native builds.
  * See the documentation in android/build.gradle.
* For iOS and MacOS: Xcode, via CocoaPods.
  * See the documentation in ios/open62541_libs.podspec.
  * See the documentation in macos/open62541_libs.podspec.
* For Linux and Windows: CMake.
  * See the documentation in linux/CMakeLists.txt.
  * See the documentation in windows/CMakeLists.txt.

## Binding to native code

To use the native code, bindings in Dart are needed.
To avoid writing these by hand, they are generated from the header file
(`src/open62541_libs.h`) by `package:ffigen`.
Regenerate the bindings by running `dart run ffigen --config ffigen.yaml`.

## Invoking native code

Very short-running native functions can be directly invoked from any isolate.
For example, see `sum` in `lib/open62541_libs.dart`.

Longer-running functions should be invoked on a helper isolate to avoid
dropping frames in Flutter applications.
For example, see `sumAsync` in `lib/open62541_libs.dart`.

## Flutter help

For help getting started with Flutter, view our
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# Important notes

## Macos

Enable networking, otherwise it will fail silently.
'*.entitlements' file should be in the Runner folder.

```
	<key>com.apple.security.network.server</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
```

## Linux

Tweak the linker in the CMakeLists.txt file to include all symbols from the open62541 library.

```
# Make sure the open62541 library is built before the binary
add_dependencies(${BINARY_NAME} open62541)
# Include all symbols from the open62541 library
target_link_options(${BINARY_NAME} PRIVATE 
  "-Wl,--whole-archive" 
  "${PROJECT_BINARY_DIR}/plugins/open62541_libs/open62541-prefix/src/open62541-build/bin/libopen62541.a"
  "-Wl,--no-whole-archive"
)
# Add the -rdynamic flag to export all symbols of the executable / open62541 library
set_target_properties(${BINARY_NAME} PROPERTIES
    ENABLE_EXPORTS ON
    LINK_FLAGS "-rdynamic"
)
```

## Windows

Tweak the linker in the CMakeLists.txt file to include all symbols from the open62541 library.

```
target_link_libraries(${BINARY_NAME} PRIVATE
  ws2_32
  iphlpapi
)

target_link_options(${BINARY_NAME} PRIVATE
  "/WHOLEARCHIVE:${open62541_libs_bundled_libraries}"
)
```
