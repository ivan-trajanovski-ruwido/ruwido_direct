import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';

class ConfigView extends ConsumerWidget {
  const ConfigView({Key? key, required this.rcuInfo}) : super(key: key);

  final RcuInformation rcuInfo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('config')),
      body: Center(
        child: Text('connected to device with model number: ${rcuInfo.modelNumber}'),
      ),
    );
  }
}
