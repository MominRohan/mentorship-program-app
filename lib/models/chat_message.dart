/*
Developer: Momin Rohan
Chat Message Model with File Sharing Support
*/

class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? replyToMessageId;
  final List<MessageAttachment> attachments;
  final Map<String, dynamic>? metadata;
  final DateTime? editedAt;
  final bool isDeleted;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.type,
    required this.timestamp,
    required this.status,
    this.replyToMessageId,
    this.attachments = const [],
    this.metadata,
    this.editedAt,
    this.isDeleted = false,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderAvatarUrl: map['senderAvatarUrl'],
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${map['type']}',
        orElse: () => MessageType.text,
      ),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${map['status']}',
        orElse: () => MessageStatus.sent,
      ),
      replyToMessageId: map['replyToMessageId'],
      attachments: (map['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromMap(e))
          .toList() ?? [],
      metadata: map['metadata'],
      editedAt: map['editedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['editedAt'])
          : null,
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'replyToMessageId': replyToMessageId,
      'attachments': attachments.map((e) => e.toMap()).toList(),
      'metadata': metadata,
      'editedAt': editedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    String? replyToMessageId,
    List<MessageAttachment>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? editedAt,
    bool? isDeleted,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  audio,
  document,
  location,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageAttachment {
  final String id;
  final String fileName;
  final String filePath;
  final String? url;
  final AttachmentType type;
  final int fileSize;
  final String? mimeType;
  final String? thumbnailPath;
  final Map<String, dynamic>? metadata;

  MessageAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.url,
    required this.type,
    required this.fileSize,
    this.mimeType,
    this.thumbnailPath,
    this.metadata,
  });

  factory MessageAttachment.fromMap(Map<String, dynamic> map) {
    return MessageAttachment(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      url: map['url'],
      type: AttachmentType.values.firstWhere(
        (e) => e.toString() == 'AttachmentType.${map['type']}',
        orElse: () => AttachmentType.document,
      ),
      fileSize: map['fileSize'] ?? 0,
      mimeType: map['mimeType'],
      thumbnailPath: map['thumbnailPath'],
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'url': url,
      'type': type.toString().split('.').last,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'thumbnailPath': thumbnailPath,
      'metadata': metadata,
    };
  }
}

enum AttachmentType {
  image,
  video,
  audio,
  document,
  other,
}
