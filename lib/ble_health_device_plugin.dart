

import 'ble_health_device_plugin_platform_interface.dart';

class BleHealthDevicePlugin {
  Future<String?> getPlatformVersion() {
    return BleHealthDevicePluginPlatform.instance.getPlatformVersion();
  }

  Future<List<Map<String, dynamic>>> startScanning({List<String> serviceUuids = const []}) {
    return BleHealthDevicePluginPlatform.instance.startScanning(serviceUuids: serviceUuids);
  }

  Future<void> connect(String deviceId) {
    return BleHealthDevicePluginPlatform.instance.connect(deviceId);
  }

  Future<void> disconnect(String deviceId) {
    return BleHealthDevicePluginPlatform.instance.disconnect(deviceId);
  }

  Future<Map<String, dynamic>> readCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) {
    return BleHealthDevicePluginPlatform.instance.readCharacteristic(deviceId, serviceUuid, characteristicUuid);
  }

  Future<void> writeCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid, String type, int value, int timestamp) {
    return BleHealthDevicePluginPlatform.instance.writeCharacteristic(
        deviceId, serviceUuid, characteristicUuid, type, value, timestamp);
  }

  Future<Map<String, dynamic>> notifyCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) {
    return BleHealthDevicePluginPlatform.instance.notifyCharacteristic(deviceId, serviceUuid, characteristicUuid);
  }
}