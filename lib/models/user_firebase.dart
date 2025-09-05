/*
Developer: Momin Rohan
Firebase-ready User Model with Verification System
*/

class FirebaseUser {
  final String id; // Firebase UID
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String address;
  final String bio;
  final String occupation;
  final String expertise;
  final UserRole role;
  final UserVerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final String? avatarUrl;
  final Map<String, dynamic> verificationDocuments;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? fcmToken; // For push notifications

  FirebaseUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.address,
    required this.bio,
    required this.occupation,
    required this.expertise,
    required this.role,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.avatarUrl,
    this.verificationDocuments = const {},
    this.isActive = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.fcmToken,
  });

  String get fullName => '$firstName $lastName';

  factory FirebaseUser.fromFirestore(Map<String, dynamic> data, String documentId) {
    return FirebaseUser(
      id: documentId,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'] ?? '',
      bio: data['bio'] ?? '',
      occupation: data['occupation'] ?? '',
      expertise: data['expertise'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.user,
      ),
      verificationStatus: UserVerificationStatus.values.firstWhere(
        (e) => e.toString() == 'UserVerificationStatus.${data['verificationStatus']}',
        orElse: () => UserVerificationStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0),
      lastLoginAt: data['lastLoginAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'])
          : null,
      avatarUrl: data['avatarUrl'],
      verificationDocuments: Map<String, dynamic>.from(data['verificationDocuments'] ?? {}),
      isActive: data['isActive'] ?? true,
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      fcmToken: data['fcmToken'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'bio': bio,
      'occupation': occupation,
      'expertise': expertise,
      'role': role.toString().split('.').last,
      'verificationStatus': verificationStatus.toString().split('.').last,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'avatarUrl': avatarUrl,
      'verificationDocuments': verificationDocuments,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'fcmToken': fcmToken,
    };
  }

  FirebaseUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? bio,
    String? occupation,
    String? expertise,
    UserRole? role,
    UserVerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    String? avatarUrl,
    Map<String, dynamic>? verificationDocuments,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? fcmToken,
  }) {
    return FirebaseUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      expertise: expertise ?? this.expertise,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      verificationDocuments: verificationDocuments ?? this.verificationDocuments,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

enum UserRole {
  user,
  mentor,
  admin,
  superAdmin,
}

enum UserVerificationStatus {
  pending,
  inReview,
  verified,
  rejected,
  suspended,
}

class VerificationDocument {
  final String id;
  final String type; // 'identity', 'education', 'experience'
  final String fileName;
  final String fileUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime uploadedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  VerificationDocument({
    required this.id,
    required this.type,
    required this.fileName,
    required this.fileUrl,
    required this.status,
    required this.uploadedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory VerificationDocument.fromMap(Map<String, dynamic> data) {
    return VerificationDocument(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      fileName: data['fileName'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      status: data['status'] ?? 'pending',
      uploadedAt: DateTime.fromMillisecondsSinceEpoch(data['uploadedAt'] ?? 0),
      reviewedBy: data['reviewedBy'],
      reviewedAt: data['reviewedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(data['reviewedAt'])
          : null,
      reviewNotes: data['reviewNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'status': status,
      'uploadedAt': uploadedAt.millisecondsSinceEpoch,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.millisecondsSinceEpoch,
      'reviewNotes': reviewNotes,
    };
  }
}
