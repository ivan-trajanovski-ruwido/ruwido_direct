import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';
import 'package:ruwido_direct_riverpod/ui/config_view.dart';
import 'package:ruwido_direct_riverpod/ui/scan_view.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ScanView(),
    ),
    GoRoute(
      path: '/config',
      name: 'config',
      builder: (context, state) {
        final rcuInfo = state.extra! as RcuInformation;
        return ConfigView(
          rcuInfo: rcuInfo,
        );
      },
    ),
  ],
);

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        title: "ruwido direct",
      ),
    ),
  );
}

// class RuwidoDirect extends StatelessWidget {
//   const RuwidoDirect({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter BLE Demo',
//       home: ScanView(),
//     );
//   }
// }
