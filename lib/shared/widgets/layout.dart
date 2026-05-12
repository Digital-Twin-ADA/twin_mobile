import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/navigation/widgets/navigation.dart';
import '../../features/chatbot/widgets/chatbot_widget.dart';

class Layout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const Layout({
    super.key,
    required this.navigationShell,
  });

  void _openChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return const ChatbotWidget();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
        elevation: 0,
      ),
      body: navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatbot(context),
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: Navigation(navigationShell: navigationShell),
    );
  }
}