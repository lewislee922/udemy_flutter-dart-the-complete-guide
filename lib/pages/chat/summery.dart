import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_page.dart';
import '../../models/message_group.dart';
import '../../pages/chat/messange_detail.dart';
import '../../provider.dart';
import '../../services/chat/chat_data_service.dart';

class Summery extends ConsumerWidget {
  final RealtimeChatDataService _service;
  final User _user;

  const Summery(this._service, this._user, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainNavigationBar(
      extendBodyBehindAppBar: false,
      appBarTitle: const Text("Chats"),
      actions: [
        Container(
          height: 30,
          width: 30,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: FutureBuilder<String>(
              future: _service.avatorLink(_user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.network(snapshot.data!);
                }
                return const Icon(Icons.person);
              }),
        ),
        TextButton(
          onPressed: () => ref.read(chatService).signOut(),
          child: const Text("sign out"),
        )
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<String> selectedId = List.empty(growable: true);
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: const Text("Create chat group"),
                    children: [
                      SingleChildScrollView(
                        child: FutureBuilder(
                            future: _service.getUsers(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                var data = Map<String, dynamic>.from(
                                    (snapshot.data!.value as Map));
                                final List<ChatUser> users =
                                    List<ChatUser>.empty(growable: true);
                                for (final key in data.keys) {
                                  final user = Map<String, dynamic>.from(
                                      (data[key] as Map));
                                  users.add(ChatUser.fromMap(user, key));
                                }
                                return StatefulBuilder(
                                    builder: (context, newState) {
                                  return Column(
                                    children: users
                                        .map<Widget>((user) => CheckboxListTile(
                                            title: Text(user.name),
                                            value: selectedId.contains(user.id),
                                            onChanged: (value) {
                                              if (value!) {
                                                selectedId.add(user.id);
                                              } else {
                                                selectedId.remove(user.id);
                                              }
                                              newState(() => selectedId);
                                            }))
                                        .toList(),
                                  );
                                });
                              }
                              return const CircularProgressIndicator();
                            }),
                      ),
                      TextButton.icon(
                          onPressed: () => _service.addNewGroup(
                              "new chat group", selectedId),
                          icon: const Icon(Icons.chat_rounded),
                          label: const Text("create"))
                    ],
                  ));
        },
        child: const Icon(Icons.add),
      ),
      child: Center(
          child: StreamBuilder(
        stream: _service.getMessages(ref.watch(chatService).currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                for (final dataSnapshot in snapshot.data!)
                  FutureBuilder(
                      future: _service.getSinkUsers(dataSnapshot.snapshot.key!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final users = List<ChatUser>.from(snapshot.data!)
                            ..removeWhere((element) =>
                                element.id ==
                                ref.read(chatService).currentUser!.uid);

                          return ListTile(
                            title: Text(users.first.name),
                            // pass group data & message sink
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => MessageDetail(
                                        groupId: dataSnapshot.snapshot.key!,
                                        groupUsers:
                                            List<ChatUser>.from(snapshot.data!),
                                        service: _service))),
                            leading: Container(
                                clipBehavior: Clip.hardEdge,
                                height: 50,
                                width: 50,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: Image.network(
                                  users.first.avatarURL,
                                  fit: BoxFit.cover,
                                )),
                          );
                        }

                        return const CircularProgressIndicator();
                      }),
              ],
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const Center(child: Text("No messange group to display."));
          }
          return const CircularProgressIndicator();
        },
      )),
    );
  }
}
