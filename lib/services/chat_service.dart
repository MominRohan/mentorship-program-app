/*
Developer: Momin Rohan
Chat Service for Local Database Operations
*/

import 'package:sqflite/sqflite.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import 'db_helper.dart';

class ChatService {
  static const String _chatRoomsTable = 'chat_rooms';
  static const String _messagesTable = 'messages';
  static const String _participantsTable = 'chat_participants';
  static const String _attachmentsTable = 'message_attachments';

  // Initialize chat tables
  static Future<void> createChatTables(Database db) async {
    // Chat rooms table
    await db.execute('''
      CREATE TABLE $_chatRoomsTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        participantIds TEXT NOT NULL,
        lastMessageId TEXT,
        lastMessage TEXT,
        lastMessageTime INTEGER,
        lastMessageSenderId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        imageUrl TEXT,
        isActive INTEGER DEFAULT 1,
        unreadCounts TEXT DEFAULT '{}'
      )
    ''');

    // Messages table
    await db.execute('''
      CREATE TABLE $_messagesTable (
        id TEXT PRIMARY KEY,
        chatRoomId TEXT NOT NULL,
        senderId TEXT NOT NULL,
        senderName TEXT NOT NULL,
        senderAvatarUrl TEXT,
        content TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL,
        replyToMessageId TEXT,
        metadata TEXT,
        editedAt INTEGER,
        isDeleted INTEGER DEFAULT 0,
        FOREIGN KEY (chatRoomId) REFERENCES $_chatRoomsTable (id)
      )
    ''');

    // Chat participants table
    await db.execute('''
      CREATE TABLE $_participantsTable (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        chatRoomId TEXT NOT NULL,
        name TEXT NOT NULL,
        avatarUrl TEXT,
        role TEXT NOT NULL,
        joinedAt INTEGER NOT NULL,
        lastSeenAt INTEGER,
        isActive INTEGER DEFAULT 1,
        FOREIGN KEY (chatRoomId) REFERENCES $_chatRoomsTable (id)
      )
    ''');

    // Message attachments table
    await db.execute('''
      CREATE TABLE $_attachmentsTable (
        id TEXT PRIMARY KEY,
        messageId TEXT NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        url TEXT,
        type TEXT NOT NULL,
        fileSize INTEGER NOT NULL,
        mimeType TEXT,
        thumbnailPath TEXT,
        metadata TEXT,
        FOREIGN KEY (messageId) REFERENCES $_messagesTable (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_chatroom ON $_messagesTable (chatRoomId, timestamp)');
    await db.execute('CREATE INDEX idx_messages_sender ON $_messagesTable (senderId)');
    await db.execute('CREATE INDEX idx_participants_chatroom ON $_participantsTable (chatRoomId)');
    await db.execute('CREATE INDEX idx_participants_user ON $_participantsTable (userId)');
  }

  // Chat Room Operations
  Future<List<ChatRoom>> getChatRooms([String? userId]) async {
    final db = await DBHelper.database;
    String query = 'SELECT * FROM $_chatRoomsTable WHERE isActive = 1';
    List<dynamic> args = [];

    if (userId != null) {
      query += ' AND participantIds LIKE ?';
      args.add('%$userId%');
    }

    query += ' ORDER BY updatedAt DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    return maps.map((map) {
      final chatRoom = ChatRoom.fromMap(map);
      return chatRoom.copyWith(
        participantIds: (map['participantIds'] as String).split(','),
        unreadCounts: _parseUnreadCounts(map['unreadCounts']),
      );
    }).toList();
  }

  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _chatRoomsTable,
      where: 'id = ?',
      whereArgs: [chatRoomId],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return ChatRoom.fromMap(map).copyWith(
      participantIds: (map['participantIds'] as String).split(','),
      unreadCounts: _parseUnreadCounts(map['unreadCounts']),
    );
  }

  Future<void> createChatRoom(ChatRoom chatRoom) async {
    final db = await DBHelper.database;
    final map = chatRoom.toMap();
    map['participantIds'] = chatRoom.participantIds.join(',');
    map['unreadCounts'] = _stringifyUnreadCounts(chatRoom.unreadCounts);
    
    await db.insert(_chatRoomsTable, map);

    // Add participants
    for (String participantId in chatRoom.participantIds) {
      await addParticipant(ChatParticipant(
        id: '${chatRoom.id}_$participantId',
        userId: participantId,
        chatRoomId: chatRoom.id,
        name: 'User $participantId', // This should be fetched from user data
        role: ParticipantRole.member,
        joinedAt: DateTime.now(),
      ));
    }
  }

  Future<void> updateChatRoom(ChatRoom chatRoom) async {
    final db = await DBHelper.database;
    final map = chatRoom.toMap();
    map['participantIds'] = chatRoom.participantIds.join(',');
    map['unreadCounts'] = _stringifyUnreadCounts(chatRoom.unreadCounts);
    
    await db.update(
      _chatRoomsTable,
      map,
      where: 'id = ?',
      whereArgs: [chatRoom.id],
    );
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    final db = await DBHelper.database;
    await db.update(
      _chatRoomsTable,
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [chatRoomId],
    );
  }

  // Message Operations
  Future<List<ChatMessage>> getMessages(String chatRoomId, {int limit = 50, int offset = 0}) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _messagesTable,
      where: 'chatRoomId = ? AND isDeleted = 0',
      whereArgs: [chatRoomId],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    List<ChatMessage> messages = [];
    for (var map in maps) {
      final attachments = await getMessageAttachments(map['id']);
      messages.add(ChatMessage.fromMap(map).copyWith(attachments: attachments));
    }

    return messages.reversed.toList(); // Return in chronological order
  }

  Future<void> sendMessage(ChatMessage message) async {
    final db = await DBHelper.database;
    
    await db.transaction((txn) async {
      // Insert message
      await txn.insert(_messagesTable, message.toMap());
      
      // Insert attachments
      for (var attachment in message.attachments) {
        final attachmentMap = attachment.toMap();
        attachmentMap['messageId'] = message.id;
        await txn.insert(_attachmentsTable, attachmentMap);
      }
      
      // Update chat room's last message
      await txn.update(
        _chatRoomsTable,
        {
          'lastMessage': message.content,
          'lastMessageTime': message.timestamp.millisecondsSinceEpoch,
          'lastMessageSenderId': message.senderId,
          'lastMessageId': message.id,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [message.chatRoomId],
      );
    });
  }

  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    final db = await DBHelper.database;
    await db.update(
      _messagesTable,
      {'status': status.toString().split('.').last},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final db = await DBHelper.database;
    await db.update(
      _messagesTable,
      {'isDeleted': 1},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> editMessage(String messageId, String newContent) async {
    final db = await DBHelper.database;
    await db.update(
      _messagesTable,
      {
        'content': newContent,
        'editedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  // Attachment Operations
  Future<List<MessageAttachment>> getMessageAttachments(String messageId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _attachmentsTable,
      where: 'messageId = ?',
      whereArgs: [messageId],
    );

    return maps.map((map) => MessageAttachment.fromMap(map)).toList();
  }

  // Participant Operations
  Future<void> addParticipant(ChatParticipant participant) async {
    final db = await DBHelper.database;
    await db.insert(_participantsTable, participant.toMap());
  }

  Future<List<ChatParticipant>> getChatParticipants(String chatRoomId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _participantsTable,
      where: 'chatRoomId = ? AND isActive = 1',
      whereArgs: [chatRoomId],
    );

    return maps.map((map) => ChatParticipant.fromMap(map)).toList();
  }

  Future<void> removeParticipant(String chatRoomId, String userId) async {
    final db = await DBHelper.database;
    await db.update(
      _participantsTable,
      {'isActive': 0},
      where: 'chatRoomId = ? AND userId = ?',
      whereArgs: [chatRoomId, userId],
    );
  }

  // Unread count operations
  Future<Map<String, int>> getUnreadCounts([String? userId]) async {
    final db = await DBHelper.database;
    String query = '''
      SELECT chatRoomId, COUNT(*) as unreadCount
      FROM $_messagesTable m
      JOIN $_chatRoomsTable c ON m.chatRoomId = c.id
      WHERE m.status != 'read' AND c.isActive = 1
    ''';
    
    List<dynamic> args = [];
    if (userId != null) {
      query += ' AND m.senderId != ? AND c.participantIds LIKE ?';
      args.addAll([userId, '%$userId%']);
    }
    
    query += ' GROUP BY chatRoomId';

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);
    
    Map<String, int> unreadCounts = {};
    for (var map in maps) {
      unreadCounts[map['chatRoomId']] = map['unreadCount'];
    }
    
    return unreadCounts;
  }

  Future<void> markMessagesAsRead(String chatRoomId, String userId) async {
    final db = await DBHelper.database;
    await db.update(
      _messagesTable,
      {'status': 'read'},
      where: 'chatRoomId = ? AND senderId != ? AND status != ?',
      whereArgs: [chatRoomId, userId, 'read'],
    );
  }

  // Search messages
  Future<List<ChatMessage>> searchMessages(String query, {String? chatRoomId}) async {
    final db = await DBHelper.database;
    String sql = '''
      SELECT * FROM $_messagesTable 
      WHERE content LIKE ? AND isDeleted = 0
    ''';
    List<dynamic> args = ['%$query%'];

    if (chatRoomId != null) {
      sql += ' AND chatRoomId = ?';
      args.add(chatRoomId);
    }

    sql += ' ORDER BY timestamp DESC LIMIT 100';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    
    List<ChatMessage> messages = [];
    for (var map in maps) {
      final attachments = await getMessageAttachments(map['id']);
      messages.add(ChatMessage.fromMap(map).copyWith(attachments: attachments));
    }

    return messages;
  }

  // Helper methods
  Map<String, int> _parseUnreadCounts(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      // Simple parsing for key-value pairs
      final Map<String, dynamic> parsed = {};
      // This is a simplified version - in real app, use proper JSON parsing
      return Map<String, int>.from(parsed);
    } catch (e) {
      return {};
    }
  }

  String _stringifyUnreadCounts(Map<String, int> unreadCounts) {
    // Simple stringification - in real app, use proper JSON encoding
    return unreadCounts.toString();
  }

  // Create one-on-one chat
  Future<ChatRoom> createOneOnOneChat(String userId1, String userId2, String user1Name, String user2Name) async {
    final chatRoomId = 'chat_${userId1}_${userId2}_${DateTime.now().millisecondsSinceEpoch}';
    final chatRoom = ChatRoom(
      id: chatRoomId,
      name: '$user1Name & $user2Name',
      type: ChatType.oneOnOne,
      participantIds: [userId1, userId2],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createChatRoom(chatRoom);
    return chatRoom;
  }

  // Check if one-on-one chat exists
  Future<ChatRoom?> findOneOnOneChat(String userId1, String userId2) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM $_chatRoomsTable 
      WHERE type = 'oneOnOne' 
      AND isActive = 1
      AND (
        (participantIds LIKE '%$userId1%' AND participantIds LIKE '%$userId2%')
      )
    ''');

    if (maps.isEmpty) return null;

    final map = maps.first;
    return ChatRoom.fromMap(map).copyWith(
      participantIds: (map['participantIds'] as String).split(','),
      unreadCounts: _parseUnreadCounts(map['unreadCounts']),
    );
  }
}
