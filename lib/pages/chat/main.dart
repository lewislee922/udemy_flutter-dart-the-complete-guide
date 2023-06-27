import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_page.dart';
import '../../pages/chat/animated_logo.dart';
import '../../pages/chat/login.dart';
import '../../pages/chat/summery.dart';
import '../../provider.dart';
import '../../services/chat/chat_data_service.dart';

class ChatMain extends ConsumerWidget {
  const ChatMain({Key? key}) : super(key: key);

  static Page page() => const MaterialPage(
      key: ValueKey('chat'), name: 'chat', child: ChatMain());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
      stream: ref.watch(chatService).listenAuthChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            final userdata = snapshot.data!;
            return Summery(RealtimeChatDataService(), userdata);
          } else {
            return const MainNavigationBar(child: Login());
          }
        }
        return const MainNavigationBar(
          child: Center(
            child: AnimatedLogo(),
          ),
        );
      },
    );
  }
}
