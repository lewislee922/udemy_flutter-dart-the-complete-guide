import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:rxdart/streams.dart';

import '../../models/message_group.dart';

// abstract class ChatDataService {}

class RealtimeChatDataService {
  FirebaseDatabase get _instance => FirebaseDatabase.instance;

  Future<String> avatorLink(String userId) async {
    final result = await _instance
        .ref('users/$userId/avator')
        .once(DatabaseEventType.value);
    return result.snapshot.value as String;
  }

  Future<DataSnapshot> getUsers() {
    return _instance.ref('users').get();
  }

  Future<String> addNewGroup(String name, List<String> attendeeId) async {
    final groupRef = _instance.ref('chats/groups').push();
    final now = DateTime.now().millisecondsSinceEpoch;
    await groupRef.update({'name': name, 'createdtime': now});
    for (final id in attendeeId) {
      final messageSinkRef = _instance.ref('chats/messagesinks').push();
      await messageSinkRef.update({
        'userId': id,
        'groupId': groupRef.key,
        'createTime': now,
        'user_group': "$id  ${groupRef.key}"
      });
    }
    return groupRef.key!;
  }

  Future<void> deleteGroup(String groupId) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    await _instance.ref('chats/groups/$groupId').update({'deleteTime': date});
    await stopGroupSink(groupId, date);
  }

  Future<void> stopGroupSink(String groupId, int endTime) async {
    final ref =
        _instance.ref('chats/messagesinks').child('groupId').equalTo(groupId);
    await ref.get().then((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.value! as Map<String, dynamic>;
        for (final key in data.keys) {
          await _instance
              .ref('chats/messagesinks/$key')
              .update({'endTime': endTime});
        }
      }
    });
  }

  Future<void> leaveGroupSink(
      String groupId, int endTime, String userId) async {
    final ref =
        _instance.ref('chat/messagesinks').equalTo('userId').equalTo(userId);
    await ref.get().then((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.value! as Map<String, dynamic>;
        data.removeWhere((key, value) => value['groupId'] != groupId);
        final key = data.keys.first;
        await _instance
            .ref('chats/messagesinks/$key')
            .update({'endTime': endTime});
      }
    });
  }

  Future<void> addMessage(Message message, String userId) async {
    var newMessage = message.copyWith();
    final messagesRef =
        _instance.ref('chats/messages/${newMessage.groupId}').push();
    await messagesRef.update(newMessage.toMap());
  }

  Future<DataSnapshot> getUser(String userId) =>
      _instance.ref('/users/$userId').get();

  Future<List<ChatUser>> getSinkUsers(String groupId) async {
    final sinks = await _instance
        .ref('/chats/messagesinks')
        .orderByChild('groupId')
        .equalTo(groupId)
        .once(DatabaseEventType.value);
    if (sinks.snapshot.exists) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(sinks.snapshot.value! as Map);
      final List<ChatUser> users = List<ChatUser>.empty(growable: true);
      for (final key in data.keys) {
        final userId = data[key]['userId'];
        final usersnapshot = await getUser(userId);
        final userMap = Map<String, dynamic>.from(usersnapshot.value! as Map);
        users.add(ChatUser.fromMap(userMap, userId));
      }
      return users;
    }
    return List<ChatUser>.empty(growable: false);
  }

  Stream<DatabaseEvent> getUserMessageSink(String userId, String groupId) {
    return _instance
        .ref('chats/messagesinks')
        .orderByChild('user_group')
        .equalTo('$userId  $groupId')
        .onValue;
  }

  Stream<DatabaseEvent> getSingleSinkMessages(Map<String, dynamic> sink) {
    final key = sink.keys.first;
    final groupId = sink[key]['groupId'] as String;

    return _instance
        .ref('chats/messages/$groupId')
        .orderByChild('sendTime')
        .startAt(sink[key]['startTime'])
        .endAt(sink[key]['endTime'] ?? DateTime(9999).millisecondsSinceEpoch)
        .onValue;
  }

  Stream<List<DatabaseEvent>> getMessages(String userId) async* {
    final sinks = await _instance
        .ref('chats/messagesinks')
        .orderByChild('userId')
        .equalTo(userId)
        .get();
    if (sinks.value != null) {
      Map<String, dynamic> object = jsonDecode(jsonEncode(sinks.value));
      object = Map<String, dynamic>.from(object);

      final List<Stream<DatabaseEvent>> groups = <Stream<DatabaseEvent>>[];
      for (final sink in object.keys) {
        final groupId = object[sink]['groupId'] as String;
        final messageSteam = _instance
            .ref('chats/messages/$groupId')
            .orderByChild('sendTime')
            .startAt(object[sink]['startTime'])
            .endAt(object[sink]['endTime'] ??
                DateTime(9999).millisecondsSinceEpoch)
            .onValue;
        groups.add(messageSteam);
      }
      final combined = CombineLatestStream.list(groups);
      yield* combined;
    }
  }
}
