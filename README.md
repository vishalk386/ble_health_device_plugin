# ble_health_device_plugin

# BLE Health Device Plugin

A secure, modular Flutter plugin for managing Bluetooth Low Energy (BLE) communication with multiple smart health devices. Built on `SmartBLEHealthDeviceSDK` (iOS) and `smart_ble_health_device_sdk` (Android), this plugin provides a unified Dart API to scan, connect, and exchange encrypted health data (e.g., heart rate, glucose) with device-specific access control and scalable architecture.

## Features

- **Multi-Device Support**: Seamlessly integrates N different BLE health devices, each with its own native SDK.
- **Secure Data Handling**: Encrypts/decrypts health data using AES-256 for secure BLE communication.
- **Device-Specific Access Control**: Restricts features to authorized devices via, enforced via configuration.
- **Modular Architecture**: Easily add/remove device SDKs without affecting existing implementations.
- **Robust BLE Operations**: Scan, connect, read, write, and notify characteristics with robust error handling.
- **Cross-Platform**: Supports Android (API 21+) and iOS (12.0+).

## Installation

### Prerequisites

- Flutter 3.3.0+
- Dart 2.18.0+
- **Android**: Min SDK 21, device-specific AARs (e.g., `smart_ble_health_device_sdk-release.aar`)
- **iOS**: iOS 12.0+, device-specific XCFrameworks (e.g., `SmartBLEHealthDeviceSDK.xcframework`)
- Bluetooth and location permissions

### Setup

1. **Add Dependencies**:
   In your app’s `pubspec.yaml`:

   ```yaml
   dependencies:
     ble_health_device_plugin:
       path: ../ble_health_device_plugin
     permission_handler: ^10.2.0

Run flutter pub get

Android:
Ensure native SDK dependencies are configured in ble_health_device_plugin/android/build.gradle:
gradle

dependencies {
implementation 'androidx.core:core-ktx:1.13.1'
implementation 'androidx.appcompat:appcompat:1.7.0'
}

Add to android/app/src/main/AndroidManifest.xml:
xml

<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

iOS:
Ensure native SDK dependencies are configured in ble_health_device_plugin/ios/ble_health_device_plugin.podspec.

Run pod install in ble_health_device_plugin/ios/.

Add to ios/Runner/Info.plist:
xml

<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth is needed for health devices.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth is needed for health devices.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is needed for Bluetooth scanning.</string>

Usage
Configure Devices
Set allowed devices and operations:
dart

import 'package:ble_health_device_plugin/ble_health_device_plugin.dart';

Future<void> configureDevices() async {
await BleHealthDevicePlugin.configureDevices([
{'deviceId': '123e4567-e89b-12d3-a456-426614174000', 'deviceType': 'GLUCOSE', 'operations': ['read', 'write']},
]);
}

Request Permissions
dart

import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
await [
Permission.bluetoothScan,
Permission.bluetoothConnect,
Permission.locationWhenInUse,
].request();
}

Example
dart

import 'package:ble_health_device_plugin/ble_health_device_plugin.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
const MyApp({super.key});
@override
Widget build(BuildContext context) => MaterialApp(home: const MyHomePage());
}

class MyHomePage extends StatefulWidget {
const MyHomePage({super.key});
@override
State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
List<Map<String, dynamic>> devices = [];
String? connectedDeviceId;

Future<void> setup() async {
await [
Permission.bluetoothScan,
Permission.bluetoothConnect,
Permission.locationWhenInUse,
].request();
await BleHealthDevicePlugin.configureDevices([
{'deviceId': '123e4567-e89b-12d3-a456-426614174000', 'deviceType': 'GLUCOSE', 'operations': ['read', 'write']},
]);
}

@override
void initState() {
super.initState();
setup();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('BLE Health Devices')),
body: Column(
children: [
Expanded(
child: ListView.builder(
itemCount: devices.length,
itemBuilder: (context, index) {
final device = devices[index];
return ListTile(
title: Text(device['name'] ?? 'Unknown'),
subtitle: Text(device['id']),
trailing: device['id'] == connectedDeviceId
? const Icon(Icons.link, color: Colors.green)
: null,
onTap: () async {
try {
await BleHealthDevicePlugin.connect(device['id']);
setState(() => connectedDeviceId = device['id']);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Connected')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
},
);
},
),
),
if (connectedDeviceId != null)
Padding(
padding: const EdgeInsets.all(8.0),
child: Column(
children: [
ElevatedButton(
onPressed: () async {
try {
final data = await BleHealthDevicePlugin.readCharacteristic(
connectedDeviceId!,
'00001808-0000-1000-8000-00805f9b34fb',
'00002a18-0000-1000-8000-00805f9b34fb',
);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Read: $data')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
},
child: const Text('Read'),
),
ElevatedButton(
onPressed: () async {
try {
await BleHealthDevicePlugin.writeCharacteristic(
connectedDeviceId!,
'00001808-0000-1000-8000-00805f9b34fb',
'00002a18-0000-1000-8000-00805f9b34fb',
'GLUCOSE',
120,
DateTime.now().millisecondsSinceEpoch,
);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Write successful')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
},
child: const Text('Write'),
),
ElevatedButton(
onPressed: () async {
try {
final data = await BleHealthDevicePlugin.notifyCharacteristic(
connectedDeviceId!,
'00001808-0000-1000-8000-00805f9b34fb',
'00002a18-0000-1000-8000-00805f9b34fb',
);
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Notify: $data')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
},
child: const Text('Notify'),
),
],
),
),
],
),
floatingActionButton: FloatingActionButton(
onPressed: () async {
try {
final scannedDevices = await BleHealthDevicePlugin.startScanning();
setState(() => devices = scannedDevices);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Error: $e')),
);
}
},
child: const Icon(Icons.search),
),
);
}
}

Note: Replace UUIDs with your device’s service and characteristic UUIDs.
Security
Encryption: AES-256 secures health data during communication.

Access Control: Limits operations to configured devices.

Key Storage: Uses Android KeyStore and iOS Keychain.



