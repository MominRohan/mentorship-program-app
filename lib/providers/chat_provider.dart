/*
Developer: Momin Rohan
Chat Provider using Riverpod for State Management
*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

// Chat Service Provider
final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

// Chat Rooms State Provider
final chatRoomsProvider = StateNotifierProvider<ChatRoomsNotifier, AsyncValue<List<ChatRoom>>>((ref) {
  return ChatRoomsNotifier(ref.read(chatServiceProvider));
});

// Messages for specific chat room
final messagesProvider = StateNotifierProvider.family<MessagesNotifier, AsyncValue<List<ChatMessage>>, String>((ref, chatRoomId) {
  return MessagesNotifier(ref.read(chatServiceProvider), chatRoomId);
});

// Current chat room provider
final currentChatRoomProvider = StateProvider<ChatRoom?>((ref) => null);

// Typing indicator provider
final typingIndicatorProvider = StateNotifierProvider.family<TypingNotifier, Set<String>, String>((ref, chatRoomId) {
  return TypingNotifier();
});

// Unread messages count provider
final unreadCountProvider = StateNotifierProvider<UnreadCountNotifier, Map<String, int>>((ref) {
  return UnreadCountNotifier(ref.read(chatServiceProvider));
});

// Online users provider
final onlineUsersProvider = StateNotifierProvider<OnlineUsersNotifier, Set<String>>((ref) {
  return OnlineUsersNotifier();
});

class ChatRoomsNotifier extends StateNotifier<AsyncValue<List<ChatRoom>>> {
  final ChatService _chatService;

  ChatRoomsNotifier(this._chatService) : super(const AsyncValue.loading()) {
    loadChatRooms();
  }

  Future<void> loadChatRooms() async {
    try {
      state = const AsyncValue.loading();
      final chatRooms = await _chatService.getChatRooms();
      state = AsyncValue.data(chatRooms);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createChatRoom(ChatRoom chatRoom) async {
    try {
      await _chatService.createChatRoom(chatRoom);
      await loadChatRooms(); // Refresh the list
    } catch (error) {
      // Handle error
      rethrow;
    }
  }

  Future<void> updateChatRoom(ChatRoom chatRoom) async {
    try {
      await _chatService.updateChatRoom(chatRoom);
      await loadChatRooms(); // Refresh the list
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      await _chatService.deleteChatRoom(chatRoomId);
      await loadChatRooms(); // Refresh the list
    } catch (error) {
      rethrow;
    }
  }

  void updateLastMessage(String chatRoomId, ChatMessage message) {
    state.whenData((chatRooms) {
      final updatedRooms = chatRooms.map((room) {
        if (room.id == chatRoomId) {
          return room.copyWith(
            lastMessage: message.content,
            lastMessageTime: message.timestamp,
            lastMessageSenderId: message.senderId,
            lastMessageId: message.id,
          );
        }
        return room;
      }).toList();
      state = AsyncValue.data(updatedRooms);
    });
  }
}

class MessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final ChatService _chatService;
  final String chatRoomId;

  MessagesNotifier(this._chatService, this.chatRoomId) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      state = const AsyncValue.loading();
      final messages = await _chatService.getMessages(chatRoomId);
      state = AsyncValue.data(messages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> sendMessage(ChatMessage message) async {
    try {
      // Optimistically add message to UI
      state.whenData((messages) {
        final updatedMessages = [...messages, message];
        state = AsyncValue.data(updatedMessages);
      });

      // Send to database
      await _chatService.sendMessage(message);
      
      // Reload to get the actual saved message
      await loadMessages();
    } catch (error) {
      // Remove optimistic message on error
      await loadMessages();
      rethrow;
    }
  }

  Future<void> updateMessageStatus(String messageId, MessageStatus status) async {
    try {
      await _chatService.updateMessageStatus(messageId, status);
      await loadMessages(); // Refresh messages
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.deleteMessage(messageId);
      await loadMessages(); // Refresh messages
    } catch (error) {
      rethrow;
    }
  }

  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _chatService.editMessage(messageId, newContent);
      await loadMessages(); // Refresh messages
    } catch (error) {
      rethrow;
    }
  }

  void addMessage(ChatMessage message) {
    state.whenData((messages) {
      final updatedMessages = [...messages, message];
      state = AsyncValue.data(updatedMessages);
    });
  }
}

class TypingNotifier extends StateNotifier<Set<String>> {
  TypingNotifier() : super({});

  void startTyping(String userId) {
    state = {...state, userId};
  }

  void stopTyping(String userId) {
    state = state.where((id) => id != userId).toSet();
  }

  void clearTyping() {
    state = {};
  }
}

class UnreadCountNotifier extends StateNotifier<Map<String, int>> {
  final ChatService _chatService;

  UnreadCountNotifier(this._chatService) : super({}) {
    loadUnreadCounts();
  }

  Future<void> loadUnreadCounts() async {
    try {
      final counts = await _chatService.getUnreadCounts();
      state = counts;
    } catch (error) {
      // Handle error
    }
  }

  void incrementUnread(String chatRoomId) {
    state = {
      ...state,
      chatRoomId: (state[chatRoomId] ?? 0) + 1,
    };
  }

  void markAsRead(String chatRoomId) {
    final newState = Map<String, int>.from(state);
    newState.remove(chatRoomId);
    state = newState;
  }

  void updateUnreadCount(String chatRoomId, int count) {
    if (count <= 0) {
      final newState = Map<String, int>.from(state);
      newState.remove(chatRoomId);
      state = newState;
    } else {
      state = {
        ...state,
        chatRoomId: count,
      };
    }
  }
}

class OnlineUsersNotifier extends StateNotifier<Set<String>> {
  OnlineUsersNotifier() : super({});

  void setUserOnline(String userId) {
    state = {...state, userId};
  }

  void setUserOffline(String userId) {
    state = state.where((id) => id != userId).toSet();
  }

  void updateOnlineUsers(Set<String> onlineUsers) {
    state = onlineUsers;
  }
}

// Helper providers for UI
final totalUnreadCountProvider = Provider<int>((ref) {
  final unreadCounts = ref.watch(unreadCountProvider);
  return unreadCounts.values.fold(0, (sum, count) => sum + count);
});

final chatRoomUnreadCountProvider = Provider.family<int, String>((ref, chatRoomId) {
  final unreadCounts = ref.watch(unreadCountProvider);
  return unreadCounts[chatRoomId] ?? 0;
});

final isUserOnlineProvider = Provider.family<bool, String>((ref, userId) {
  final onlineUsers = ref.watch(onlineUsersProvider);
  return onlineUsers.contains(userId);
});

final isUserTypingProvider = Provider.family<bool, String>((ref, chatRoomId) {
  final typingUsers = ref.watch(typingIndicatorProvider(chatRoomId));
  return typingUsers.isNotEmpty;
});
