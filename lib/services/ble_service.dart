import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ruwido_direct_riverpod/services/rcu/manufacturer_data_ruwido_parser.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';

final bleProvider = Provider<BleService>((ref) {
  return BleService(ref);
});

class BleService {
  final Ref ref;
  final FlutterReactiveBle flutterReactiveBle;
  StreamSubscription? _scanSubscription;
  final _discoveredDevices = <DiscoveredDevice>[];
  final _minRssi = -65;

  BleService(this.ref) : flutterReactiveBle = FlutterReactiveBle();

  Stream<List<DiscoveredDevice>> get discoveredDevicesStream => flutterReactiveBle.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
      ).map((device) {
        if (device.rssi >= _minRssi) {
          final rcu = _parseManufacturerData(device);
          if (rcu != null &&
              rcu.information.randomNumber == null &&
              rcu.information.macAddress == null &&
              rcu.information.version != null &&
              !_discoveredDevices.any((d) => d.id == device.id)) {
            _discoveredDevices.add(device);
          }
        }
        return _discoveredDevices;
      });

  Future<Rcu?> scanRcu() async {
    final completer = Completer<Rcu?>();
    _scanSubscription = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.rssi >= _minRssi) {
        final rcu = _parseManufacturerData(device);
        if (rcu != null &&
            rcu.information.randomNumber == null &&
            rcu.information.macAddress == null &&
            rcu.information.version != null) {
          _scanSubscription?.cancel();
          if (!completer.isCompleted) {
            completer.complete(rcu);
          }
        }
      }
    }, onError: (error) {
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    });

    return completer.future;
  }

  Rcu? _parseManufacturerData(DiscoveredDevice device) {
    var manufacturerData = device.manufacturerData;

    if (manufacturerData.isNotEmpty) {
      var manufacturerId = manufacturerData.buffer.asByteData().getUint16(0, Endian.little);
      if (manufacturerId == 0x027f) {
        try {
          var data = manufacturerData.sublist(2);
          var parseResult = ManufacturerDataRuwidoParser.parse(data);
          return Rcu(device, parseResult);
        } catch (e) {
          // Handle parsing error
          return null;
        }
      }
    }

    return null;
  }

  void addDiscoveredDevice(DiscoveredDevice device) {
    if (!_discoveredDevices.any((d) => d.id == device.id)) {
      _discoveredDevices.add(device);
    }
  }

  DiscoveredDevice _getDiscoveredDeviceById(String deviceId) {
    var foundDevice = _discoveredDevices.firstWhere((device) => device.id == deviceId,
        orElse: () => throw Exception("Device not found"));
    return foundDevice;
  }

  Future<RcuInformation?> connectToDevice(String deviceId) async {
    try {
      var device = _getDiscoveredDeviceById(deviceId);
      await flutterReactiveBle
          .connectToDevice(
            id: deviceId,
            connectionTimeout: const Duration(seconds: 5),
          )
          .first;

      RcuInformation? rcuInfo = ManufacturerDataRuwidoParser.parse(device.manufacturerData);

      return rcuInfo;
    } catch (e) {
      // Handle connection error
      return null;
    }
  }
}
