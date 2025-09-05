/*
Developer: SERGE MUNEZA
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
  });

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
    );
  }
}
