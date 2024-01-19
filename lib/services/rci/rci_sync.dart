import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:async';
import 'dart:typed_data';

class RciSync {
  static final Uuid _rciServiceUuid = Uuid.parse("0000fe0b-0000-1000-8000-00805F9B34FB");
  static final Uuid _rciTunnelUuid = Uuid.parse("00000002-bebc-4ca4-a6f8-bb896399027f");

  final FlutterReactiveBle _ble;
  final DiscoveredDevice _device;
  QualifiedCharacteristic? _rciTunnel;

  RciSync(this._ble, this._device);

  Future<void> initialize() async {
    var services = await _ble.discoverServices(_device.id);
    var rciService = services.firstWhere((s) => s.serviceId == _rciServiceUuid);

    _rciTunnel =
        QualifiedCharacteristic(serviceId: _rciServiceUuid, characteristicId: _rciTunnelUuid, deviceId: _device.id);

    // Subscribe to notifications
    _ble.subscribeToCharacteristic(_rciTunnel!);
  }

  Future<int> getBatteryLevel() async {
    if (_rciTunnel == null) {
      throw Exception("RCI tunnel not initialized");
    }
    const int getBatteryLevelCommand = 0x21;
    Uint8List commandData = Uint8List.fromList([getBatteryLevelCommand]);
    await _ble.writeCharacteristicWithResponse(
      _rciTunnel!,
      value: commandData,
    );
    final response = await _ble.readCharacteristic(_rciTunnel!);

    return response.isNotEmpty ? response[0] : -1;
  }
}
