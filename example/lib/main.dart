import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';

// import 'package:open62541_libs/open62541_libs.dart' as open62541_libs;
import 'package:open62541_libs/src/generated/open62541_bindings.dart' as raw;


void main() {
  var lib = raw.open62541(DynamicLibrary.executable());
  Pointer<raw.UA_Client> client = lib.UA_Client_new();
  Pointer<raw.UA_ClientConfig> clientConfigPointer = lib.UA_Client_getConfig(client);
  lib.UA_ClientConfig_setDefault(clientConfigPointer);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                spacerSmall,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
