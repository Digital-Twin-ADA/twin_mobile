import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/widgets/navigation.dart';

class Layout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const Layout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // ref.read(authenticationProvider.notifier).signOut();
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        child: navigationShell,
      ),
      bottomNavigationBar: Navigation(navigationShell: navigationShell),
    );
  }
}