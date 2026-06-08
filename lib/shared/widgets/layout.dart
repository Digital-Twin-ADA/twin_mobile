import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/chatbot/widgets/chatbot_widget.dart';
import '../../features/festival_map/providers/participant_location_sender_provider.dart';
import '../../features/navigation/widgets/navigation.dart';

class Layout extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const Layout({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<Layout> createState() => _LayoutState();
}

class _LayoutState extends ConsumerState<Layout> with WidgetsBindingObserver {
  late final ParticipantLocationSender _sender;

  @override
  void initState() {
    super.initState();

    _sender = ref.read(participantLocationSenderProvider);

    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      _sender.start();
    });
  }

  @override
  void dispose() {
    _sender.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sender.start();
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _sender.stop();
    }
  }

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
  Widget build(BuildContext context) {
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
      body: widget.navigationShell,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openChatbot(context),
        child: const Icon(Icons.chat),
      ),
      bottomNavigationBar: Navigation(navigationShell: widget.navigationShell),
    );
  }
}