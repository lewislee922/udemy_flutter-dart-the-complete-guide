import 'dart:convert';

class MessageGroup {
  final String id;
  final String name;
  final DateTime createTime;
  final DateTime? deleteTime;

  MessageGroup({
    required this.id,
    required this.name,
    required this.createTime,
    this.deleteTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createTime': createTime.millisecondsSinceEpoch,
      'deleteTime': deleteTime?.millisecondsSinceEpoch,
    };
  }

  factory MessageGroup.fromMap(Map<String, dynamic> map, String id) {
    return MessageGroup(
      id: id,
      name: map['name'] ?? '',
      createTime: DateTime.fromMillisecondsSinceEpoch(map['createTime']),
      deleteTime: map['deleteTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deleteTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());
}

class ChatUser {
  final String id;
  final String name;
  final String avatarURL;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatarURL,
  });

  ChatUser copyWith({
    String? id,
    String? name,
    String? avatarURL,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarURL: avatarURL ?? this.avatarURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarURL': avatarURL,
    };
  }

  factory ChatUser.fromMap(Map<String, dynamic> map, String id) {
    return ChatUser(
      id: id,
      name: map['name'] ?? '',
      avatarURL: map['avator'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'ChatUser(id: $id, name: $name, avatarURL: $avatarURL)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatUser &&
        other.id == id &&
        other.name == name &&
        other.avatarURL == avatarURL;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ avatarURL.hashCode;
}

class Message {
  final String? id;
  final String groupId;
  final String senderId;
  final String content;
  final DateTime sendTime;
  final String? attachmentURL;

  Message({
    this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    required this.sendTime,
    this.attachmentURL,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'sendTime': sendTime.millisecondsSinceEpoch,
      'attachmentURL': attachmentURL,
    };
  }

  factory Message.fromMap(
      Map<String, dynamic> map, String groupId, String key) {
    final data = map;
    return Message(
      id: key,
      groupId: groupId,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      sendTime: DateTime.fromMillisecondsSinceEpoch(data['sendTime']),
      attachmentURL: data['attachmentURL'],
    );
  }

  String toJson() => json.encode(toMap());

  Message copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? content,
    DateTime? sendTime,
    String? attachmentURL,
  }) {
    return Message(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      sendTime: sendTime ?? this.sendTime,
      attachmentURL: attachmentURL ?? this.attachmentURL,
    );
  }

  @override
  String toString() {
    return 'Message(id: $id, groupId: $groupId, senderId: $senderId, content: $content, sendTime: $sendTime, attachmentURL: $attachmentURL)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.groupId == groupId &&
        other.senderId == senderId &&
        other.content == content &&
        other.sendTime == sendTime &&
        other.attachmentURL == attachmentURL;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        groupId.hashCode ^
        senderId.hashCode ^
        content.hashCode ^
        sendTime.hashCode ^
        attachmentURL.hashCode;
  }
}

class MessageSection {
  final List<Message> messages;
  final ChatUser user;
  MessageSection(this.user, this.messages);
}

// class MessageSink {
//   final String id;
//   final String userId;
//   final String groupId;
//   final DateTime createTime;
//   final DateTime? endTime;
//   final String user_group;
// }

/// query messenage: sink(where: userid, orderby createTime) 
/// for each
///  -> get message during periods (where: groupid && sendtime during period, orderby: createTime) 
///    -> turn data to UI
/// database path:
///   /chats
///     /users
///     /groups
///     /messages
///       /{groupId}
///         /{uid}
///     /messagesinks
///       /{uid}