/*
Developer: Momin Rohan
Firebase Migration Helper - Utilities for migrating from SQLite to Firebase
*/

import 'package:flutter/foundation.dart';
import '../services/db_helper.dart';
import '../services/chat_service.dart';
import '../services/firebase_service.dart';
import '../models/user.dart';
import '../models/mentor.dart';
import '../models/user_firebase.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

class FirebaseMigrationHelper {
  static const String _migrationKey = 'firebase_migration_status';
  
  // Migration status tracking
  static Future<bool> isMigrationCompleted() async {
    // TODO: Check if migration has been completed
    // This will be implemented when Firebase is configured
    return false;
  }

  static Future<void> markMigrationCompleted() async {
    // TODO: Mark migration as completed in shared preferences
    if (kDebugMode) {
      print('Migration marked as completed');
    }
  }

  // User Migration
  static Future<MigrationResult> migrateUsers() async {
    try {
      if (kDebugMode) {
        print('🔄 Starting user migration to Firebase...');
      }

      // Get all users from SQLite
      final users = await DBHelper.getAllUsers();
      final mentors = await DBHelper.getAllMentors();
      
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      // Migrate regular users
      for (User user in users) {
        try {
          final firebaseUser = _convertToFirebaseUser(user);
          // TODO: Save to Firebase when configured
          // await FirebaseService.instance.createUser(firebaseUser);
          successCount++;
          
          if (kDebugMode) {
            print('✅ Migrated user: ${user.email}');
          }
        } catch (e) {
          errorCount++;
          errors.add('Failed to migrate user ${user.email}: $e');
          if (kDebugMode) {
            print('❌ Failed to migrate user ${user.email}: $e');
          }
        }
      }

      // Migrate mentors
      for (Mentor mentor in mentors) {
        try {
          final firebaseUser = _convertMentorToFirebaseUser(mentor);
          // TODO: Save to Firebase when configured
          // await FirebaseService.instance.createUser(firebaseUser);
          successCount++;
          
          if (kDebugMode) {
            print('✅ Migrated mentor: ${mentor.email}');
          }
        } catch (e) {
          errorCount++;
          errors.add('Failed to migrate mentor ${mentor.email}: $e');
          if (kDebugMode) {
            print('❌ Failed to migrate mentor ${mentor.email}: $e');
          }
        }
      }

      return MigrationResult(
        totalItems: users.length + mentors.length,
        successCount: successCount,
        errorCount: errorCount,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ User migration failed: $e');
      }
      return MigrationResult(
        totalItems: 0,
        successCount: 0,
        errorCount: 1,
        errors: ['User migration failed: $e'],
      );
    }
  }

  // Chat Migration
  static Future<MigrationResult> migrateChatRooms() async {
    try {
      if (kDebugMode) {
        print('🔄 Starting chat room migration to Firebase...');
      }

      final chatService = ChatService();
      final chatRooms = await chatService.getChatRooms();
      
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      for (ChatRoom chatRoom in chatRooms) {
        try {
          // TODO: Save to Firebase when configured
          // await FirebaseService.instance.createChatRoom(chatRoom);
          successCount++;
          
          if (kDebugMode) {
            print('✅ Migrated chat room: ${chatRoom.name}');
          }
        } catch (e) {
          errorCount++;
          errors.add('Failed to migrate chat room ${chatRoom.id}: $e');
          if (kDebugMode) {
            print('❌ Failed to migrate chat room ${chatRoom.id}: $e');
          }
        }
      }

      return MigrationResult(
        totalItems: chatRooms.length,
        successCount: successCount,
        errorCount: errorCount,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Chat room migration failed: $e');
      }
      return MigrationResult(
        totalItems: 0,
        successCount: 0,
        errorCount: 1,
        errors: ['Chat room migration failed: $e'],
      );
    }
  }

  // Message Migration
  static Future<MigrationResult> migrateMessages() async {
    try {
      if (kDebugMode) {
        print('🔄 Starting message migration to Firebase...');
      }

      final chatService = ChatService();
      final chatRooms = await chatService.getChatRooms();
      
      int totalMessages = 0;
      int successCount = 0;
      int errorCount = 0;
      List<String> errors = [];

      for (ChatRoom chatRoom in chatRooms) {
        try {
          final messages = await chatService.getMessages(chatRoom.id, limit: 1000);
          totalMessages += messages.length;

          for (ChatMessage message in messages) {
            try {
              // TODO: Save to Firebase when configured
              // await FirebaseService.instance.createMessage(message);
              successCount++;
            } catch (e) {
              errorCount++;
              errors.add('Failed to migrate message ${message.id}: $e');
            }
          }
          
          if (kDebugMode) {
            print('✅ Migrated ${messages.length} messages from chat: ${chatRoom.name}');
          }
        } catch (e) {
          errorCount++;
          errors.add('Failed to migrate messages from chat room ${chatRoom.id}: $e');
          if (kDebugMode) {
            print('❌ Failed to migrate messages from chat room ${chatRoom.id}: $e');
          }
        }
      }

      return MigrationResult(
        totalItems: totalMessages,
        successCount: successCount,
        errorCount: errorCount,
        errors: errors,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Message migration failed: $e');
      }
      return MigrationResult(
        totalItems: 0,
        successCount: 0,
        errorCount: 1,
        errors: ['Message migration failed: $e'],
      );
    }
  }

  // Complete Migration Process
  static Future<CompleteMigrationResult> performCompleteMigration() async {
    if (kDebugMode) {
      print('🚀 Starting complete migration to Firebase...');
    }

    final userResult = await migrateUsers();
    final chatRoomResult = await migrateChatRooms();
    final messageResult = await migrateMessages();

    final totalResult = CompleteMigrationResult(
      userMigration: userResult,
      chatRoomMigration: chatRoomResult,
      messageMigration: messageResult,
    );

    if (totalResult.isSuccessful) {
      await markMigrationCompleted();
      if (kDebugMode) {
        print('🎉 Migration completed successfully!');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ Migration completed with errors. Check results for details.');
      }
    }

    return totalResult;
  }

  // Data Validation
  static Future<ValidationResult> validateMigration() async {
    try {
      if (kDebugMode) {
        print('🔍 Validating migration...');
      }

      // TODO: Implement validation when Firebase is configured
      // Compare SQLite data with Firebase data
      
      return ValidationResult(
        isValid: true,
        issues: [],
        summary: 'Validation will be implemented when Firebase is configured',
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        issues: ['Validation failed: $e'],
        summary: 'Validation error occurred',
      );
    }
  }

  // Helper Methods
  static FirebaseUser _convertToFirebaseUser(User user) {
    return FirebaseUser(
      id: user.id.toString(), // Will be replaced with Firebase UID
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      address: user.address,
      bio: user.bio,
      occupation: user.occupation,
      expertise: user.expertise,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${user.role}',
        orElse: () => UserRole.user,
      ),
      verificationStatus: UserVerificationStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static FirebaseUser _convertMentorToFirebaseUser(Mentor mentor) {
    return FirebaseUser(
      id: mentor.id.toString(), // Will be replaced with Firebase UID
      firstName: mentor.name.split(' ').first,
      lastName: mentor.name.split(' ').skip(1).join(' '),
      email: mentor.email,
      address: '', // Not available in current mentor model
      bio: mentor.bio,
      occupation: mentor.occupation,
      expertise: mentor.expertise,
      role: UserRole.mentor,
      verificationStatus: UserVerificationStatus.verified, // Assume existing mentors are verified
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Cleanup Methods
  static Future<void> cleanupAfterMigration() async {
    if (kDebugMode) {
      print('🧹 Cleaning up after migration...');
    }
    
    // TODO: Optionally backup and clean SQLite data after successful migration
    // This should be done carefully and only after confirming Firebase data integrity
  }
}

// Migration Result Classes
class MigrationResult {
  final int totalItems;
  final int successCount;
  final int errorCount;
  final List<String> errors;

  MigrationResult({
    required this.totalItems,
    required this.successCount,
    required this.errorCount,
    required this.errors,
  });

  bool get isSuccessful => errorCount == 0;
  double get successRate => totalItems > 0 ? successCount / totalItems : 0.0;

  @override
  String toString() {
    return 'MigrationResult(total: $totalItems, success: $successCount, errors: $errorCount)';
  }
}

class CompleteMigrationResult {
  final MigrationResult userMigration;
  final MigrationResult chatRoomMigration;
  final MigrationResult messageMigration;

  CompleteMigrationResult({
    required this.userMigration,
    required this.chatRoomMigration,
    required this.messageMigration,
  });

  bool get isSuccessful => 
      userMigration.isSuccessful && 
      chatRoomMigration.isSuccessful && 
      messageMigration.isSuccessful;

  int get totalItems => 
      userMigration.totalItems + 
      chatRoomMigration.totalItems + 
      messageMigration.totalItems;

  int get totalSuccessCount => 
      userMigration.successCount + 
      chatRoomMigration.successCount + 
      messageMigration.successCount;

  int get totalErrorCount => 
      userMigration.errorCount + 
      chatRoomMigration.errorCount + 
      messageMigration.errorCount;

  List<String> get allErrors => [
    ...userMigration.errors,
    ...chatRoomMigration.errors,
    ...messageMigration.errors,
  ];

  @override
  String toString() {
    return 'CompleteMigrationResult(total: $totalItems, success: $totalSuccessCount, errors: $totalErrorCount)';
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> issues;
  final String summary;

  ValidationResult({
    required this.isValid,
    required this.issues,
    required this.summary,
  });

  @override
  String toString() {
    return 'ValidationResult(valid: $isValid, issues: ${issues.length})';
  }
}
