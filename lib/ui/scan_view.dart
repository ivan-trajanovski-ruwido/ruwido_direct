import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruwido_direct_riverpod/services/ble_service.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';

class ScanView extends ConsumerStatefulWidget {
  @override
  _ScanViewState createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView> {
  Rcu? foundRcu;

  @override
  void initState() {
    super.initState();
    requestPermissionsAndStartScanning();
  }

  Future<void> requestPermissionsAndStartScanning() async {
    if (await requestPermissions()) {
      findRcuDevice();
    } else {
      // handle case where permissions are not granted
      // show a snackbar
    }
  }

  Future<void> findRcuDevice() async {
    try {
      var rcu = await ref.read(bleProvider).scanRcu();
      setState(() {
        foundRcu = rcu;
      });
    } catch (e) {
      // Handle exceptions during scanning
    }
  }

  Future<bool> requestPermissions() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<void> connectAndNavigate(DiscoveredDevice device) async {
    final bleService = ref.read(bleProvider);
    RcuInformation? rcuInfo = await bleService.connectToDevice(device.id);

    if (!mounted) return;

    if (rcuInfo != null) {
      context.goNamed('config', extra: rcuInfo);
    } else {
      // Handle connection failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleService = ref.read(bleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Devices'),
      ),
      body: StreamBuilder<List<DiscoveredDevice>>(
        stream: bleService.discoveredDevicesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
            final devices = snapshot.data!;
            if (devices.isEmpty) {
              return const Center(child: Text('No devices found'));
            }
            return ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name.isNotEmpty ? device.name : device.id),
                  trailing: ElevatedButton(
                    child: const Text('Connect'),
                    onPressed: () => connectAndNavigate(device),
                  ),
                );
              },
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text('Failed to fetch devices'));
          }
        },
      ),
    );
  }
}
