import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';

class Rcu {
  final DiscoveredDevice device;
  final RcuInformation information;

  Rcu(this.device, this.information);

  @override
  String toString() {
    return "{device: $device, information: $information}";
  }
}
