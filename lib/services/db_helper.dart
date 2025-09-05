/*
Momin Rohan
 */
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/mentor.dart';
import '../models/session.dart';
import 'chat_service.dart';

class DBHelper {
  static Database? _database;

  // Initialize Database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB();
      return _database!;
    } catch (e) {
      print("❌ Database initialization failed: $e");
      rethrow;
    }
  }

  // Create Database & Tables
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'mentors_app.db');
    return openDatabase(
      path,
      version: 4, // Update version if modifying schema
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Add age column if it doesn't exist
          await db.execute('ALTER TABLE users ADD COLUMN age INTEGER');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firstName TEXT NOT NULL,
            lastName TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            address TEXT DEFAULT '',
            bio TEXT DEFAULT '',
            occupation TEXT DEFAULT '',
            expertise TEXT DEFAULT '',
            role TEXT DEFAULT 'user' NOT NULL,
            isVerified INTEGER DEFAULT 0,
            age INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE mentorship_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userEmail TEXT NOT NULL,
            mentorEmail TEXT NOT NULL,
            questions TEXT NOT NULL,
            isApproved INTEGER DEFAULT 0
          )
        ''');
  }

// Insert New User (Signup)
  static Future<int> insertUser(User user) async {
    final db = await database;

    // Prevent empty required fields from being inserted
    if (user.firstName.isEmpty ||
        user.lastName.isEmpty ||
        user.email.isEmpty ||
        user.password.isEmpty) {
      print("❌ Signup failed: Required fields are empty!");
      return -1; // Indicate error
    }

    // Check if email already exists
    List<Map<String, dynamic>> existingUsers = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [user.email],
    );

    if (existingUsers.isNotEmpty) {
      print("❌ Signup failed: Email '${user.email}' already exists!");
      return -1;
    }

    try {
      int result = await db.insert("users", user.toJson());
      print("✅ User inserted: ${user.email}");
      return result;
    } catch (e) {
      print("❌ Error inserting user: $e");
      return -1;
    }
  }

  // Get User by Email (Login)
  static Future<User?> getUserByEmail(String email) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    if (results.isNotEmpty) {
      print("✅ User found: ${results.first['email']}");
      return User.fromJson(results.first);
    }
    print("❌ User not found: $email");
    return null;
  }

  // Fetch all users
  static Future<List<User>> getAllUsers() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      "users",
      where: "role = ?",
      whereArgs: ["user"],
    );

    return results.map((data) => User.fromJson(data)).toList();
  }

  // Promote User to Mentor
  static Future<int> promoteUserToMentor(String email) async {
    final db = await database;
    int result = await db.update(
      "users",
      {"role": "mentor"},
      where: "email = ?",
      whereArgs: [email],
    );

    if (result > 0) {
      print("✅ User promoted to mentor: $email");
    } else {
      print("❌ Failed to promote user: No matching email found!");
    }

    return result;
  }

  // Get all mentors (Users with role = "mentor")
  static Future<List<Mentor>> getAllMentors() async {
    try {
      final db = await database;
      List<Map<String, dynamic>> results = await db.query(
        "users",
        where: "role = ?",
        whereArgs: ["mentor"],
      );

      if (results.isEmpty) {
        print("❌ No mentors found in the database!");
        return [];
      } else {
        print("✅ Mentors found: ${results.length}");
      }

      return results
          .map((data) => Mentor(
                id: data["id"],
                name:
                    "${data["firstName"] ?? 'Unknown'} ${data["lastName"] ?? ''}"
                        .trim(),
                email: data["email"] ?? "", // ✅ Ensure email is included
                bio: data["bio"] ?? "No bio available",
                occupation: data["occupation"] ?? "Unknown occupation",
                expertise: data["expertise"] ?? "Unknown expertise",
                isVerified: data["isVerified"] == 1,
              ))
          .toList();
    } catch (e) {
      print("❌ Error fetching mentors: $e");
      return [];
    }
  }

  // Insert Mentorship Session Request
  static Future<int> requestSession(MentorshipSession session) async {
    final db = await database;
    return await db.insert("mentorship_sessions", session.toJson());
  }

  // Get All Mentorship Session Requests for a Mentor
  static Future<List<MentorshipSession>> getMentorSessions(
      String mentorEmail) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      "mentorship_sessions",
      where: "mentorEmail = ?",
      whereArgs: [mentorEmail],
    );

    return results.map((data) => MentorshipSession.fromJson(data)).toList();
  }

  // Get All Mentorship Sessions for a User
  static Future<List<MentorshipSession>> getUserSessions(
      String userEmail) async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query(
      "mentorship_sessions",
      where: "userEmail = ?",
      whereArgs: [userEmail],
    );

    return results.map((data) => MentorshipSession.fromJson(data)).toList();
  }

  // Get All Mentorship Sessions (For Admin)
  static Future<List<MentorshipSession>> getAllSessions() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query("mentorship_sessions");

    return results.map((data) => MentorshipSession.fromJson(data)).toList();
  }

  // Delete users with empty required fields
  static Future<int> deleteEmptyUsers() async {
    try {
      final db = await database;
      int deletedRows = await db.delete(
        "users",
        where: "firstName = '' OR lastName = '' OR email = '' OR password = ''",
      );

      print("✅ Deleted $deletedRows empty users.");
      return deletedRows;
    } catch (e) {
      print("❌ Error deleting empty users: $e");
      return 0;
    }
  }

// Approve a mentorship session
  static Future<int> approveSession(int sessionId) async {
    final db = await database;
    return await db.update(
      "mentorship_sessions",
      {"isApproved": 1}, // 1 = Approved
      where: "id = ?",
      whereArgs: [sessionId],
    );
  }

// Reject a mentorship session
  static Future<int> rejectSession(int sessionId) async {
    final db = await database;
    return await db.update(
      "mentorship_sessions",
      {"isApproved": -1}, // -1 = Rejected
      where: "id = ?",
      whereArgs: [sessionId],
    );
  }

  // Update user verification status
  static Future<int> updateUserVerification(int userId, bool isVerified) async {
    final db = await database;
    return await db.update(
      "users",
      {"isVerified": isVerified ? 1 : 0},
      where: "id = ?",
      whereArgs: [userId],
    );
  }

  // Update mentor verification status
  static Future<int> updateMentorVerification(int userId, bool isVerified) async {
    final db = await database;
    return await db.update(
      "users",
      {"isVerified": isVerified ? 1 : 0},
      where: "id = ? AND role = 'mentor'",
      whereArgs: [userId],
    );
  }

  // Delete user by ID
  static Future<int> deleteUser(int userId) async {
    final db = await database;
    return await db.delete(
      "users",
      where: "id = ?",
      whereArgs: [userId],
    );
  }

  // Delete mentor by ID
  static Future<int> deleteMentor(int userId) async {
    final db = await database;
    return await db.delete(
      "users",
      where: "id = ? AND role = 'mentor'",
      whereArgs: [userId],
    );
  }

  // Get all users including admins and mentors
  static Future<List<User>> getAllUsersIncludingRoles() async {
    final db = await database;
    List<Map<String, dynamic>> results = await db.query("users");
    return results.map((data) => User.fromJson(data)).toList();
  }

  // Update user role
  static Future<int> updateUserRole(int userId, String newRole) async {
    final db = await database;
    return await db.update(
      "users",
      {"role": newRole},
      where: "id = ?",
      whereArgs: [userId],
    );
  }
}
