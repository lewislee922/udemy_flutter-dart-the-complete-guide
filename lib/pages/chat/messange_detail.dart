import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/main_page.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/provider.dart';
import 'package:udemy_flutter_dart_the_complete_guide_course_demo/services/chat/chat_data_service.dart';

import '../../models/message_group.dart';

class MessageDetail extends ConsumerStatefulWidget {
  final String groupId;
  final List<ChatUser> groupUsers;
  final RealtimeChatDataService _service;

  const MessageDetail(
      {super.key,
      required this.groupId,
      required this.groupUsers,
      required RealtimeChatDataService service})
      : _service = service;

  @override
  MessageDetailState createState() => MessageDetailState();
}

class MessageDetailState extends ConsumerState<MessageDetail> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarTitle: FutureBuilder<Object>(
          future: null,
          builder: (context, snapshot) {
            return const Text("None");
          }),
      appBarLeading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {},
        )
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: widget._service.getUserMessageSink(
                      ref.read(chatService).currentUser!.uid, widget.groupId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return StreamBuilder(
                          stream: widget._service.getSingleSinkMessages(
                              Map<String, dynamic>.from(
                                  snapshot.data!.snapshot.value as Map)),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!.snapshot.value != null) {
                              var messageSection =
                                  List<MessageSection>.empty(growable: true);
                              for (final item
                                  in snapshot.data!.snapshot.children) {
                                final message = Message.fromMap(
                                    Map<String, dynamic>.from(
                                        item.value as Map),
                                    widget.groupId,
                                    item.key as String);
                                if (messageSection.isEmpty) {
                                  final newSection = MessageSection(
                                      widget.groupUsers.firstWhere((element) =>
                                          element.id == message.senderId),
                                      List<Message>.from([message]));
                                  messageSection.add(newSection);
                                } else if (messageSection.last.user.id !=
                                    message.senderId) {
                                  final newSection = MessageSection(
                                      widget.groupUsers.firstWhere((element) =>
                                          element.id == message.senderId),
                                      List<Message>.from([message]));
                                  messageSection.add(newSection);
                                } else {
                                  messageSection.last.messages.add(message);
                                }
                              }
                              messageSection = messageSection.reversed.toList();
                              return ListView.builder(
                                reverse: true,
                                itemCount: messageSection.length,
                                itemBuilder: (context, index) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: messageSection[index]
                                              .user
                                              .id ==
                                          ref.read(chatService).currentUser!.uid
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (messageSection[index].user.id !=
                                        ref.read(chatService).currentUser!.uid)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          height: 50,
                                          width: 50,
                                          decoration: const BoxDecoration(
                                              shape: BoxShape.circle),
                                          child: Image.network(
                                              messageSection[index]
                                                  .user
                                                  .avatarURL,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            messageSection[index].user.id ==
                                                    ref
                                                        .read(chatService)
                                                        .currentUser!
                                                        .uid
                                                ? CrossAxisAlignment.end
                                                : CrossAxisAlignment.start,
                                        children: [
                                          if (messageSection[index].user.id !=
                                              ref
                                                  .read(chatService)
                                                  .currentUser!
                                                  .uid)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                              child: Text(messageSection[index]
                                                  .user
                                                  .name),
                                            ),
                                          ...messageSection[index]
                                              .messages
                                              .map((e) => Container(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(e.content)))
                                              .toList()
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return const SizedBox();
                            }
                          });
                    }

                    return const Center(
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Text to send message",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final userId = ref.read(chatService).currentUser!.uid;
                    final newMessage = Message(
                        groupId: widget.groupId,
                        senderId: userId,
                        content: _controller.text,
                        sendTime: DateTime.now());
                    await widget._service.addMessage(newMessage, userId);
                    _controller.clear();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
