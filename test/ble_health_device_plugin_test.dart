import 'package:flutter_test/flutter_test.dart';
import 'package:ble_health_device_plugin/ble_health_device_plugin.dart';
import 'package:ble_health_device_plugin/ble_health_device_plugin_platform_interface.dart';
import 'package:ble_health_device_plugin/ble_health_device_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockBleHealthDevicePluginPlatform
    with MockPlatformInterfaceMixin
    implements BleHealthDevicePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> connect(String deviceId) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect(String deviceId) {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> notifyCharacteristic(String deviceId, String serviceUuid, String characteristicUuid) {
    // TODO: implement notifyCharacteristic
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> readCharacteristic(String deviceId, String serviceUuid, String characteristicUuid) {
    // TODO: implement readCharacteristic
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> startScanning({List<String> serviceUuids = const []}) {
    // TODO: implement startScanning
    throw UnimplementedError();
  }

  @override
  Future<void> writeCharacteristic(String deviceId, String serviceUuid, String characteristicUuid, String type, int value, int timestamp) {
    // TODO: implement writeCharacteristic
    throw UnimplementedError();
  }
}

void main() {
  final BleHealthDevicePluginPlatform initialPlatform = BleHealthDevicePluginPlatform.instance;

  test('$MethodChannelBleHealthDevicePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelBleHealthDevicePlugin>());
  });

  test('getPlatformVersion', () async {
    BleHealthDevicePlugin bleHealthDevicePlugin = BleHealthDevicePlugin();
    MockBleHealthDevicePluginPlatform fakePlatform = MockBleHealthDevicePluginPlatform();
    BleHealthDevicePluginPlatform.instance = fakePlatform;

    expect(await bleHealthDevicePlugin.getPlatformVersion(), '42');
  });
}
