package com.vishal.ble_health_device_plugin

import android.content.Context
import androidx.annotation.NonNull
import com.example.smart_ble_health_device_sdk.DeviceConfiguration
import com.example.smart_ble_health_device_sdk.DeviceType
import com.example.smart_ble_health_device_sdk.HealthBLEManager
import com.example.smart_ble_health_device_sdk.devices.HealthData
import com.example.smart_ble_health_device_sdk.model.HealthDataType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class BleHealthDevicePlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private lateinit var manager: HealthBLEManager

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ble_health_device_plugin")
    channel.setMethodCallHandler(this)
    val config = listOf(
      DeviceConfiguration(
        deviceId = UUID.randomUUID(),
        deviceType = DeviceType.GLUCOSE,
        allowedOperations = listOf()
      )
    )
    manager = HealthBLEManager(context, config)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "startScanning" -> {
        val serviceUuids = (call.argument<List<String>>("serviceUuids") ?: emptyList()).map { UUID.fromString(it) }
        manager.startScanning(serviceUuids) { scanResult ->
          scanResult.onSuccess { devices ->
            val deviceList = devices.map { mapOf("id" to it.id.toString(), "name" to it.name, "isConnected" to it.isConnected) }
            result.success(deviceList)
          }.onFailure { result.error("SCAN_FAILED", it.message, null) }
        }
      }
      "connect" -> {
        val deviceId = call.argument<String>("deviceId")
        if (deviceId != null) {
          manager.connect(deviceId) { connectResult ->
            connectResult.onSuccess { result.success(null) }
              .onFailure { result.error("CONNECT_FAILED", it.message, null) }
          }
        } else {
          result.error("INVALID_ARGUMENT", "Device ID is required", null)
        }
      }
      "disconnect" -> {
        val deviceId = call.argument<String>("deviceId")
        if (deviceId != null) {
          val success = manager.disconnect(deviceId)
          if (success) {
            result.success(null)
          } else {
            result.error("DISCONNECT_FAILED", "Failed to disconnect", null)
          }
        } else {
          result.error("INVALID_ARGUMENT", "Device ID is required", null)
        }
      }
      "readCharacteristic" -> {
        val deviceId = call.argument<String>("deviceId")
        val serviceUuid = call.argument<String>("serviceUuid")?.let { UUID.fromString(it) }
        val characteristicUuid = call.argument<String>("characteristicUuid")
        if (deviceId != null && serviceUuid != null && characteristicUuid != null) {
          manager.readCharacteristic(deviceId, serviceUuid, characteristicUuid) { dataResult ->
            dataResult.onSuccess { healthData ->
              result.success(
                mapOf(
                  "type" to healthData.type.name,
                  "value" to healthData.value,
                  "timestamp" to healthData.timestamp.time
                )
              )
            }.onFailure { result.error("READ_FAILED", it.message, null) }
          }
        } else {
          result.error("INVALID_ARGUMENT", "Missing required arguments", null)
        }
      }
      "writeCharacteristic" -> {
        val deviceId = call.argument<String>("deviceId")
        val serviceUuid = call.argument<String>("serviceUuid")?.let { UUID.fromString(it) }
        val characteristicUuid = call.argument<String>("characteristicUuid")
        val type = call.argument<String>("type")?.let { HealthDataType.valueOf(it) }
        val value = call.argument<Int>("value")
        val timestamp = call.argument<Int>("timestamp")?.toLong()
        if (deviceId != null && serviceUuid != null && characteristicUuid != null && type != null && value != null && timestamp != null) {
          val healthData = HealthData(type, value, Date(timestamp))
          manager.writeCharacteristic(serviceUuid, deviceId, characteristicUuid, healthData) { writeResult ->
            writeResult.onSuccess { result.success(null) }
              .onFailure { result.error("WRITE_FAILED", it.message, null) }
          }
        } else {
          result.error("INVALID_ARGUMENT", "Missing required arguments", null)
        }
      }
      "notifyCharacteristic" -> {
        val deviceId = call.argument<String>("deviceId")
        val serviceUuid = call.argument<String>("serviceUuid")?.let { UUID.fromString(it) }
        val characteristicUuid = call.argument<String>("characteristicUuid")
        if (deviceId != null && serviceUuid != null && characteristicUuid != null) {
          manager.notifyCharacteristic(deviceId, serviceUuid, characteristicUuid) { dataResult ->
            dataResult.onSuccess { healthData ->
              result.success(
                mapOf(
                  "type" to healthData.type.name,
                  "value" to healthData.value,
                  "timestamp" to healthData.timestamp.time
                )
              )
            }.onFailure { result.error("NOTIFY_FAILED", it.message, null) }
          }
        } else {
          result.error("INVALID_ARGUMENT", "Missing required arguments", null)
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}