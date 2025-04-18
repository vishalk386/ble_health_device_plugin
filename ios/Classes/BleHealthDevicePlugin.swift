import Flutter
import UIKit
import SmartBLEHealthDeviceSDK

public class SwiftBleHealthDevicePlugin: NSObject, FlutterPlugin {
    private let manager: HealthBLEManager

    // Initialize with a default DeviceConfiguration
    public override init() {
        let config = [
            DeviceConfiguration(
                deviceId: UUID(),
                deviceType: .glucose,
                allowedOperations: [.read, .write, .notify]
            )
        ]
        manager = HealthBLEManager(configurations: config)
        super.init()
    }

    // Register the plugin with Flutter
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ble_health_device_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftBleHealthDevicePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    // Handle Method Channel calls
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)

        case "startScanning":
            let arguments = call.arguments as? [String: Any]
            let serviceUuids = (arguments?["serviceUuids"] as? [String] ?? []).compactMap { UUID(uuidString: $0) }
            manager.startScanning { scanResult in
                switch scanResult {
                case .success(let devices):
                    let deviceList = devices.map { [
                        "id": $0.id.uuidString,
                        "name": $0.name,
                        "isConnected": $0.isConnected
                    ] }
                    result(deviceList)
                case .failure(let error):
                    result(FlutterError(code: "SCAN_FAILED", message: error.localizedDescription, details: nil))
                }
            }

        case "connect":
            if let arguments = call.arguments as? [String: Any],
               let deviceIdString = arguments["deviceId"] as? String,
               let deviceId = UUID(uuidString: deviceIdString) {
                manager.connect(to: deviceId) { connectResult in
                    switch connectResult {
                    case .success:
                        result(nil)
                    case .failure(let error):
                        result(FlutterError(code: "CONNECT_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required or invalid", details: nil))
            }

        case "disconnect":
            if let arguments = call.arguments as? [String: Any],
               let deviceIdString = arguments["deviceId"] as? String,
               let deviceId = UUID(uuidString: deviceIdString) {
                manager.disconnect(from: deviceId) { disconnectResult in
                    switch disconnectResult {
                    case .success:
                        result(nil)
                    case .failure(let error):
                        result(FlutterError(code: "DISCONNECT_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Device ID is required or invalid", details: nil))
            }

        case "readCharacteristic":
            if let arguments = call.arguments as? [String: Any],
               let deviceIdString = arguments["deviceId"] as? String,
               let serviceUuidString = arguments["serviceUuid"] as? String,
               let characteristicUuid = arguments["characteristicUuid"] as? String,
               let deviceId = UUID(uuidString: deviceIdString) {
                let serviceUuid = CBUUID(string: serviceUuidString)
                manager.readCharacteristic(deviceId: deviceId, serviceUUID: serviceUuid, characteristicUUID: characteristicUuid) { dataResult in
                    switch dataResult {
                    case .success(let healthData):
                        result([
                            "type": healthData.type == .heartRate ? "HEART_RATE" : "GLUCOSE",
                            "value": healthData.value,
                            "timestamp": Int64(healthData.timestamp.timeIntervalSince1970 * 1000)
                        ])
                    case .failure(let error):
                        result(FlutterError(code: "READ_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
            }

        case "writeCharacteristic":
            if let arguments = call.arguments as? [String: Any],
               let deviceIdString = arguments["deviceId"] as? String,
               let serviceUuidString = arguments["serviceUuid"] as? String,
               let characteristicUuid = arguments["characteristicUuid"] as? String,
               let typeString = arguments["type"] as? String,
               let value = arguments["value"] as? Int,
               let timestamp = arguments["timestamp"] as? Int64,
               let deviceId = UUID(uuidString: deviceIdString) {
                let type = typeString == "HEART_RATE" ? HealthDataType.heartRate : HealthDataType.glucose
                let healthData = HealthData(type: type, value: value, timestamp: Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000))
                let serviceUuid = CBUUID(string: serviceUuidString)
                manager.writeCharacteristic(deviceId: deviceId, serviceUUID: serviceUuid, characteristicUUID: characteristicUuid, data: healthData) { writeResult in
                    switch writeResult {
                    case .success:
                        result(nil)
                    case .failure(let error):
                        result(FlutterError(code: "WRITE_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
            }

        case "notifyCharacteristic":
            if let arguments = call.arguments as? [String: Any],
               let deviceIdString = call.arguments["deviceId"] as? String,
               let serviceUuidString = arguments["serviceUuid"] as? String,
               let characteristicUuid = arguments["characteristicUuid"] as? String,
               let deviceId = UUID(uuidString: deviceIdString) {
                let serviceUuid = CBUUID(string: serviceUuidString)
                manager.listenForNotifications(deviceId: deviceId, serviceUUID: serviceUuid, characteristicUUID: characteristicUuid) { dataResult in
                    switch dataResult {
                    case .success(let healthData):
                        result([
                            "type": healthData.type == .heartRate ? "HEART_RATE" : "GLUCOSE",
                            "value": healthData.value,
                            "timestamp": Int64(healthData.timestamp.timeIntervalSince1970 * 1000)
                        ])
                    case .failure(let error):
                        result(FlutterError(code: "NOTIFY_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid arguments", details: nil))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
