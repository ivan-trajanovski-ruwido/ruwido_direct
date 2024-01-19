import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';

class RcuInformationBuilder {
  String? modelNumber;
  String? versionString;
  String? macAddress;
  int? version;
  int? randomNumber;

  RcuInformation build() {
    return RcuInformation(modelNumber, versionString, macAddress, version, randomNumber);
  }
}
