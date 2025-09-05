/*
Developer: Momin Rohan
Chat Room Model for One-on-One and Group Chats
*/

class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final ChatType type;
  final List<String> participantIds;
  final String? lastMessageId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final String? lastMessageSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final bool isActive;
  final Map<String, int> unreadCounts; // userId -> unread count

  ChatRoom({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.participantIds,
    this.lastMessageId,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.isActive = true,
    this.unreadCounts = const {},
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      type: ChatType.values.firstWhere(
        (e) => e.toString() == 'ChatType.${map['type']}',
        orElse: () => ChatType.oneOnOne,
      ),
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessageId: map['lastMessageId'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'])
          : null,
      lastMessageSenderId: map['lastMessageSenderId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString().split('.').last,
      'participantIds': participantIds,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'unreadCounts': unreadCounts,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    ChatType? type,
    List<String>? participantIds,
    String? lastMessageId,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    bool? isActive,
    Map<String, int>? unreadCounts,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      participantIds: participantIds ?? this.participantIds,
      lastMessageId: lastMessageId ?? this.lastMessageId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}

enum ChatType {
  oneOnOne,
  group,
}

class ChatParticipant {
  final String id;
  final String userId;
  final String chatRoomId;
  final String name;
  final String? avatarUrl;
  final ParticipantRole role;
  final DateTime joinedAt;
  final DateTime? lastSeenAt;
  final bool isActive;

  ChatParticipant({
    required this.id,
    required this.userId,
    required this.chatRoomId,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastSeenAt,
    this.isActive = true,
  });

  factory ChatParticipant.fromMap(Map<String, dynamic> map) {
    return ChatParticipant(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      name: map['name'] ?? '',
      avatarUrl: map['avatarUrl'],
      role: ParticipantRole.values.firstWhere(
        (e) => e.toString() == 'ParticipantRole.${map['role']}',
        orElse: () => ParticipantRole.member,
      ),
      joinedAt: DateTime.fromMillisecondsSinceEpoch(map['joinedAt']),
      lastSeenAt: map['lastSeenAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['lastSeenAt'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'chatRoomId': chatRoomId,
      'name': name,
      'avatarUrl': avatarUrl,
      'role': role.toString().split('.').last,
      'joinedAt': joinedAt.millisecondsSinceEpoch,
      'lastSeenAt': lastSeenAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }
}

enum ParticipantRole {
  admin,
  moderator,
  member,
}
