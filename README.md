# open62541_libs

This package intentionally contains no Dart code. Flutter apps depending on this package will contain native open62541 libraries on Android, iOS, macOS, Linux, and Windows.

This plugin bundles the [open62541](https://github.com/open62541/open62541) library and its dependencies(mbedTLS), allowing you to integrate OPC UA functionalities seamlessly into your Flutter projects.

## Versioning

This package currently uses fixed version of [open62541](https://github.com/open62541/open62541/tree/79e47f89837bc5e8f710d501e2afcd8ad71b0a28) and [mbedTLS](https://github.com/Mbed-TLS/mbedtls/tree/mbedtls-3.6.3).

## Predefined options of the open62541 library

The open62541 library is built with the following options:

```
-DUA_ENABLE_DEBUG_SANITIZER=OFF
-DUA_LOGLEVEL=100
-DUA_ENABLE_INLINABLE_EXPORT=ON
-DUA_ENABLE_ENCRYPTION=MBEDTLS
```

## Getting Started

### Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  open62541_libs: ^0.0.1
```

Replace `0.0.1` with the version you want to use.

### Usage

To use the open62541 library in your Flutter project, you can import the open62541 symbols in your Dart code:

```dart
import 'dart:ffi';
void main() {
  if (Platform.isAndroid) { // android cannot support static linking by design
    lib = open62541(DynamicLibrary.open('libopen62541.so'));
  } else {
    lib = open62541(DynamicLibrary.executable()); // all symbols are embedded in the executable by the build system
  }
}
```

Please refer to the [open62541_bindings](https://github.com/centroid-is/open62541_bindings) for dart bindings to the open62541 library.

## Project structure

* `windows/macos/linux/ios/android`: Contains the build files for building and bundling the native code library with the platform application.

* `example`: Contains the example code for using the open62541 library in a Flutter project.

* `.github/workflows`: Contains the CI/CD workflows for building and bundling the native code library with the example application.

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

## Android

```
defaultConfig {
  applicationId = "or app id"
  minSdk = 24 // CHANGE TO THIS REQUIREMENT BY OPEN62541
  targetSdk = flutter.targetSdkVersion
  versionCode = flutter.versionCode
  versionName = flutter.versionName
}
```

Use shared library, android does not support static linking executable
```
    lib = open62541(DynamicLibrary.open('libopen62541.so'));
```

### Included platforms

Note that, on Android, this library will bundle open62541 for all of the following platforms:

- `arm64-v8a`
- `armeabi-v7a`
- `x86`
- `x86_64`

If you don't intend to release to 32-bit `x86` devices, you'll need to apply a
[filter](https://developer.android.com/ndk/guides/abis#gc) in your `build.gradle`:

```gradle
android {
    defaultConfig {
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86_64'
        }
    }
}
```
