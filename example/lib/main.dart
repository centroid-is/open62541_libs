import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:ffi/ffi.dart';

// import 'package:open62541_libs/open62541_libs.dart' as open62541_libs;
import 'package:open62541_bindings/src/generated/open62541_bindings.dart';


late open62541 lib;
final logger = Logger();


void stateCallback(Pointer<UA_Client> client, int channelState, int sessionState, int connectStatus) {
  switch (channelState) {
    case UA_SecureChannelState.UA_SECURECHANNELSTATE_CLOSED:
      logger.d('Channel disconnected');
      break;
    case UA_SecureChannelState.UA_SECURECHANNELSTATE_HEL_SENT:
      logger.d('Channel Waiting for ack');
      break;
    case UA_SecureChannelState.UA_SECURECHANNELSTATE_OPN_SENT:
      logger.d('Channel WAITING FOR OPN RESPONSE');
      break;
    case UA_SecureChannelState.UA_SECURECHANNELSTATE_OPEN:
      logger.d('Channel A Secure channel to server is open');
      break;
  }

  switch (sessionState) {
    case UA_SessionState.UA_SESSIONSTATE_ACTIVATED:
      logger.d('Session activated');
      break;
    case UA_SessionState.UA_SESSIONSTATE_CLOSED:
      logger.d('Session closed');
      break;
    default:
      break;
  }
}

void deleteCallback(Pointer<UA_Client> client, int subscriptionId, Pointer<Void> subscriptionContext) {
  logger.d('Subscription deleted $subscriptionId');
}

void handlerCurrentTimeChanged(Pointer<UA_Client> client, int subId, Pointer<Void> subContext, int monId, Pointer<Void> monContext, Pointer<UA_DataValue> value) {
  Pointer<UA_Variant> variantPointer = malloc<UA_Variant>();
  variantPointer.ref = value.ref.value;

  // TODO: This is not working, know it is a datetime
  // Pointer<UA_DataType> datetPointer = Pointer.fromAddress(lib.UA_TYPES.address + (UA_TYPES_DATETIME * sizeOf<UA_DataType>().toInt()));
  // if (lib.UA_Variant_hasScalarType(variantPointer, datetPointer)) {
  int val = variantPointer.ref.data.cast<UA_DateTime>().value;
  UA_DateTimeStruct dts = lib.UA_DateTime_toStruct(val);
  DateTime dt = DateTime(dts.year, dts.month, dts.day, dts.hour, dts.min, dts.sec, dts.milliSec);
  logger.d(dt);
  //}
}

void subscriptionInactivityCallback(Pointer<UA_Client> client, int subId, Pointer<Void> subContext) {
  logger.d('Subscription inactivity callback $subId');
}

void main() {
  // lib = open62541(DynamicLibrary.open('libopen62541.dylib'));
  lib = open62541(DynamicLibrary.executable());
  Pointer<UA_Client> client = lib.UA_Client_new();
  Pointer<UA_ClientConfig> clientConfigPointer = lib.UA_Client_getConfig(client);
  lib.UA_ClientConfig_setDefault(clientConfigPointer);
  print("hello world1");

    // clientConfigPointer.ref.stateCallback = Pointer.fromFunction<Void Function(Pointer<UA_Client>, Int32, Int32, UA_StatusCode)>(stateCallback);

  clientConfigPointer.ref.subscriptionInactivityCallback = Pointer.fromFunction<Void Function(Pointer<UA_Client>, UA_UInt32, Pointer<Void>)>(subscriptionInactivityCallback);
  print("hello world2");

  // Pointer<Pointer<UA_EndpointDescription>> endpointDescription = nullptr;
  String endpointUrl = 'opc.tcp://localhost:4840';
  logger.d('Endpoint url: $endpointUrl');
  var statusCode = lib.UA_Client_connect(client, endpointUrl.toNativeUtf8().cast());
  logger.d('Endpoint url: $endpointUrl');
  if (statusCode == 0) {
    logger.d('Client connected!');
  } else {
    lib.UA_Client_delete(client);
    exit(-1);
  }

  logger.d("Starting read loop");
  UA_NodeId currentTimeNode = lib.UA_NODEID_NUMERIC(0, UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME);
  for (int i = 0; i < 10; i++) {
    Pointer<UA_Variant> value = malloc<UA_Variant>();
    lib.UA_Variant_init(value);
    var retvalue = lib.UA_Client_readValueAttribute(client, currentTimeNode, value);
    if (retvalue == UA_STATUSCODE_GOOD) {
      // lib.UA_Variant_hasScalarType(value, lib.UA_TYPES[UA_TYPES_DATETIME]); TODO: Find figure out how to do this
      int val = value.ref.data.cast<UA_DateTime>().value;
      UA_DateTimeStruct dts = lib.UA_DateTime_toStruct(val);
      DateTime dt = DateTime(dts.year, dts.month, dts.day, dts.hour, dts.min, dts.sec, dts.milliSec);
      logger.d(dt);
    } else {
      logger.d('Failed to read current time');
      lib.UA_Client_delete(client);
      exit(-1);
    }
    lib.UA_Variant_clear(value);
    malloc.free(value);
    sleep(Duration(milliseconds: 200));
  }

  logger.d('Read complete!');
  logger.d('Subscription!');

  //TODO: handlerCurrentTimeChanged is not being called. No errors. Need to investigate
  Pointer<UA_CreateSubscriptionRequest> request = malloc<UA_CreateSubscriptionRequest>();
  lib.UA_CreateSubscriptionRequest_init(request);
  request.ref.requestedPublishingInterval = 500.0;
  request.ref.requestedLifetimeCount = 10000;
  request.ref.requestedMaxKeepAliveCount = 10;
  request.ref.maxNotificationsPerPublish = 0;
  request.ref.publishingEnabled = true;
  request.ref.priority = 0;

  UA_CreateSubscriptionResponse response =
      lib.UA_Client_Subscriptions_create(client, request.ref, nullptr, nullptr, Pointer.fromFunction<Void Function(Pointer<UA_Client>, Uint32, Pointer<Void>)>(deleteCallback));
  if (response.responseHeader.serviceResult == UA_STATUSCODE_GOOD) {
    logger.d("Subscription created id: ${response.subscriptionId}");
  } else {
    logger.d("Failed to create subscription");
    lib.UA_Client_delete(client);
    exit(-1);
  }
  Pointer<UA_MonitoredItemCreateRequest> monRequest = malloc<UA_MonitoredItemCreateRequest>();
  lib.UA_MonitoredItemCreateRequest_init(monRequest);
  monRequest.ref.itemToMonitor.nodeId = currentTimeNode;
  monRequest.ref.itemToMonitor.attributeId = UA_AttributeId.UA_ATTRIBUTEID_VALUE;
  monRequest.ref.monitoringMode = UA_MonitoringMode.UA_MONITORINGMODE_REPORTING;
  monRequest.ref.requestedParameters.samplingInterval = 250;
  monRequest.ref.requestedParameters.discardOldest = true;
  monRequest.ref.requestedParameters.queueSize = 1;

  UA_MonitoredItemCreateResult monResponse = lib.UA_Client_MonitoredItems_createDataChange(client, response.subscriptionId, UA_TimestampsToReturn.UA_TIMESTAMPSTORETURN_BOTH, monRequest.ref, nullptr,
      Pointer.fromFunction<Void Function(Pointer<UA_Client>, Uint32, Pointer<Void>, Uint32, Pointer<Void>, Pointer<UA_DataValue>)>(handlerCurrentTimeChanged), nullptr);
  if (monResponse.statusCode == UA_STATUSCODE_GOOD) {
    logger.d('Monitored item created id: ${monResponse.monitoredItemId}');
  } else {
    logger.d('Failed to create monitored item');
    lib.UA_Client_delete(client);
    exit(-1);
  }

  logger.d('setup complete');

  var startTime = DateTime.now().millisecondsSinceEpoch;
  while (true) {
    lib.UA_Client_run_iterate(client, 100);
    if (startTime < DateTime.now().millisecondsSinceEpoch - 5000) {
      break;
    }
  }

  // calloc.free(endpointUrl);
  lib.UA_Client_delete(client);
  logger.d('Exiting');

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
