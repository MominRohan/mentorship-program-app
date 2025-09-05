/*
Developer: SERGE MUNEZA
 */

class MentorshipSession {
  final int? id;
  final String userEmail; // The user requesting mentorship
  final String mentorEmail; // The mentor receiving the request
  final String questions; // The user's questions
  final int isApproved; // 1 = Approved, 0 = Pending, -1 = Rejected

  MentorshipSession({
    this.id,
    required this.userEmail,
    required this.mentorEmail,
    required this.questions,
    this.isApproved = 0, // Default: Pending
  });

  // ✅ Convert Session object to JSON (for saving in the database)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userEmail": userEmail,
      "mentorEmail": mentorEmail,
      "questions": questions,
      "isApproved": isApproved, // Store directly as an integer (-1, 0, 1)
    };
  }

  // ✅ Convert JSON from database to Session object
  factory MentorshipSession.fromJson(Map<String, dynamic> json) {
    return MentorshipSession(
      id: json["id"],
      userEmail: json["userEmail"],
      mentorEmail: json["mentorEmail"],
      questions: json["questions"],
      isApproved: json["isApproved"], // Read as is (Supports -1, 0, 1)
    );
  }
}
