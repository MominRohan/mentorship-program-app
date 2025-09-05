import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Effective Date: September 05, 2025",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),

            // Introduction
            Text(
              "Pathway to Purpose (\"we,\" \"our,\" or \"us\") operates the Pathway to Purpose "
              "mobile application (the \"App\"). This Privacy Policy explains how we collect, "
              "use, and protect your information when you use our mentorship program.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 1
            Text("1. Information We Collect",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "- Personal Information: Name, email address, phone number, profile details.\n"
              "- Mentorship Data: Chat messages, session details, and feedback.\n"
              "- Usage Data: Device type, operating system, and app usage analytics.\n"
              "- Optional Media: Profile photos, uploaded documents, or shared files.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 2
            Text("2. How We Use Your Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "- To provide and improve mentorship services.\n"
              "- To facilitate communication between mentors and mentees.\n"
              "- To personalize your app experience.\n"
              "- To send updates, notifications, or reminders.\n"
              "- To ensure safety, prevent fraud, and comply with legal requirements.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 3
            Text("3. Sharing of Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "We do not sell your personal information.\n"
              "We may share data only with your consent, with mentors/mentees as part of the "
              "program, with service providers like Firebase, or if required by law.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 4
            Text("4. Data Storage & Security",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "Data is securely stored using Firebase (Google Cloud). "
              "We use encryption and authentication to protect your data, but no method is 100% secure.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 5
            Text("5. Your Rights",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "You may access, update, or delete your profile information. "
              "You may also request deletion of your account and associated data. "
              "For requests, contact us at: support@pathwaytopurpose.com",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 6
            Text("6. Children’s Privacy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "This app is intended for users aged 13 to 25. "
              "We do not knowingly collect personal data from anyone under 13. "
              "If we become aware, we will delete such data immediately.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 7
            Text("7. Third-Party Services",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "The app may use third-party services such as Firebase and Google Analytics. "
              "These services collect information according to their own privacy policies.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 8
            Text("8. Changes to This Policy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "We may update this Privacy Policy from time to time. "
              "Changes will be posted in the app with an updated effective date.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),

            // Section 9
            Text("9. Contact Us",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text(
              "If you have any questions, contact us at:\n\n"
              "📧 Email: support@pathwaytopurpose.com\n"
              "🌐 Website: www.pathwaytopurpose.com",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
