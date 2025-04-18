import 'package:flutter/services.dart';

import 'ble_health_device_plugin_platform_interface.dart';

class MethodChannelBleHealthDevicePlugin extends BleHealthDevicePluginPlatform {
  static const MethodChannel _channel = MethodChannel('ble_health_device_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<List<Map<String, dynamic>>> startScanning({List<String> serviceUuids = const []}) async {
    final devices = await _channel.invokeMethod('startScanning', {'serviceUuids': serviceUuids});
    return (devices as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<void> connect(String deviceId) async {
    await _channel.invokeMethod('connect', {'deviceId': deviceId});
  }

  @override
  Future<void> disconnect(String deviceId) async {
    await _channel.invokeMethod('disconnect', {'deviceId': deviceId});
  }

  @override
  Future<Map<String, dynamic>> readCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) async {
    return (await _channel.invokeMethod('readCharacteristic', {
      'deviceId': deviceId,
      'serviceUuid': serviceUuid,
      'characteristicUuid': characteristicUuid
    })) as Map<String, dynamic>;
  }

  @override
  Future<void> writeCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid, String type, int value, int timestamp) async {
    await _channel.invokeMethod('writeCharacteristic', {
      'deviceId': deviceId,
      'serviceUuid': serviceUuid,
      'characteristicUuid': characteristicUuid,
      'type': type,
      'value': value,
      'timestamp': timestamp
    });
  }

  @override
  Future<Map<String, dynamic>> notifyCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) async {
    return (await _channel.invokeMethod('notifyCharacteristic', {
      'deviceId': deviceId,
      'serviceUuid': serviceUuid,
      'characteristicUuid': characteristicUuid
    })) as Map<String, dynamic>;
  }
}
