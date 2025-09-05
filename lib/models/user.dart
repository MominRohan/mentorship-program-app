/*
Developer: Momin Rohan
 */

class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String address;
  final String bio;
  final String occupation;
  final String expertise;
  final String role;
  final bool isVerified;
  final int? age; // For mentees
  
  // Computed properties for chat system compatibility
  String get name => '$firstName $lastName';
  String? get avatarUrl => null; // Will be added when Firebase is integrated

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.address,
    required this.bio,
    required this.occupation,
    required this.expertise,
    this.role = "user",
    this.isVerified = false,
    this.age,
  });
  
  // Helper method to get string ID for chat system
  String get stringId => id?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "address": address,
      "bio": bio,
      "occupation": occupation,
      "expertise": expertise,
      "role": role,
      "isVerified": isVerified ? 1 : 0,
      "age": age,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      password: json["password"],
      address: json["address"],
      bio: json["bio"],
      occupation: json["occupation"],
      expertise: json["expertise"],
      role: json["role"],
      isVerified: json["isVerified"] == 1,
      age: json["age"],
    );
  }
}
