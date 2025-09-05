/*
Developer: SERGE MUNEZA
 */
class Mentor {
  final int? id;
  final String name;
  final String email;
  final String bio;
  final String occupation;
  final String expertise;

  Mentor({
    this.id,
    required this.name,
    required this.email,
    required this.bio,
    required this.occupation,
    required this.expertise,
  });

  // Convert Mentor object to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "bio": bio,
      "occupation": occupation,
      "expertise": expertise,
    };
  }

  // ✅ Convert JSON to Mentor object
  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json["id"],
      name: json["name"],
      email: json["email"] ?? "",
      bio: json["bio"],
      occupation: json["occupation"],
      expertise: json["expertise"],
    );
  }
}
