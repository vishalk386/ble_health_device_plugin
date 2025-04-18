import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ble_health_device_plugin_method_channel.dart';

abstract class BleHealthDevicePluginPlatform extends PlatformInterface {
  BleHealthDevicePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static BleHealthDevicePluginPlatform _instance = MethodChannelBleHealthDevicePlugin();

  static BleHealthDevicePluginPlatform get instance => _instance;

  static set instance(BleHealthDevicePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<Map<String, dynamic>>> startScanning({List<String> serviceUuids = const []}) {
    throw UnimplementedError('startScanning() has not been implemented.');
  }

  Future<void> connect(String deviceId) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<void> disconnect(String deviceId) {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<Map<String, dynamic>> readCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) {
    throw UnimplementedError('readCharacteristic() has not been implemented.');
  }

  Future<void> writeCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid, String type, int value, int timestamp) {
    throw UnimplementedError('writeCharacteristic() has not been implemented.');
  }

  Future<Map<String, dynamic>> notifyCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) {
    throw UnimplementedError('notifyCharacteristic() has not been implemented.');
  }
}
