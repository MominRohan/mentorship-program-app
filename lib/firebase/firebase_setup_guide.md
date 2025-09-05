# Firebase Setup Guide for Mentoring App

## Prerequisites
- Flutter project already set up
- Google account for Firebase Console access
- Android Studio / Xcode for platform-specific setup

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `oneals-mentoring-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Select or create Analytics account
6. Click "Create project"

## Step 2: Add Firebase to Flutter App

### Install Firebase CLI
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
```

### Configure Firebase for Flutter
```bash
# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure
```

Select your Firebase project and platforms (Android, iOS, Web).

## Step 3: Add Firebase Dependencies

Update `pubspec.yaml`:
```yaml
dependencies:
  # Existing dependencies...
  
  # Firebase Core
  firebase_core: ^2.24.2
  
  # Firebase Authentication
  firebase_auth: ^4.15.3
  
  # Cloud Firestore
  cloud_firestore: ^4.13.6
  
  # Firebase Realtime Database
  firebase_database: ^10.4.0
  
  # Firebase Storage
  firebase_storage: ^11.6.0
  
  # Firebase Messaging (Push Notifications)
  firebase_messaging: ^14.7.10
  
  # Firebase Analytics
  firebase_analytics: ^10.7.4
```

Run:
```bash
flutter pub get
```

## Step 4: Initialize Firebase in App

Update `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(ProviderScope(child: MyApp()));
}
```

## Step 5: Configure Firebase Authentication

### Enable Authentication Methods
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Email/Password
3. Enable Phone (optional, for phone verification)
4. Configure authorized domains

### Update Authentication Service
Replace the placeholder methods in `lib/services/firebase_service.dart` with actual Firebase Auth implementations.

## Step 6: Set Up Firestore Database

### Create Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in test mode (update security rules later)
4. Choose location closest to your users

### Configure Security Rules
Replace the default rules with the rules from `lib/firebase/firebase_database_structure.md`.

## Step 7: Set Up Realtime Database

### Create Realtime Database
1. Go to Firebase Console → Realtime Database
2. Click "Create Database"
3. Start in test mode
4. Choose location

### Configure Security Rules
Use the Realtime Database rules from `lib/firebase/firebase_database_structure.md`.

## Step 8: Set Up Firebase Storage

### Create Storage Bucket
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Start in test mode
4. Choose location

### Configure Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chat attachments
    match /chat_attachments/{chatRoomId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
    
    // Public files (avatars, etc.)
    match /public/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 9: Configure Push Notifications

### Android Setup
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` directory
3. Update `android/app/build.gradle`:
```gradle
dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.0.0'
}
```

### iOS Setup
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to `ios/Runner/` directory in Xcode
3. Update `ios/Runner/Info.plist` with required permissions

## Step 10: Update Firebase Service Implementation

Replace placeholder methods in `lib/services/firebase_service.dart`:

```dart
// Example implementation for user signup
Future<FirebaseUser?> signUpWithEmailAndPassword({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String address,
  required String bio,
  required String occupation,
  required String expertise,
}) async {
  try {
    // Create user with Firebase Auth
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      // Create user document in Firestore
      final firebaseUser = FirebaseUser(
        id: credential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        bio: bio,
        occupation: occupation,
        expertise: expertise,
        role: UserRole.user,
        verificationStatus: UserVerificationStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set(firebaseUser.toFirestore());
      
      // Send email verification
      await credential.user!.sendEmailVerification();
      
      return firebaseUser;
    }
  } catch (e) {
    print('Signup error: $e');
    rethrow;
  }
  return null;
}
```

## Step 11: Data Migration

### Run Migration
```dart
// In your app initialization or admin panel
final migrationResult = await FirebaseMigrationHelper.performCompleteMigration();

if (migrationResult.isSuccessful) {
  print('Migration completed successfully!');
} else {
  print('Migration completed with errors: ${migrationResult.allErrors}');
}
```

### Validate Migration
```dart
final validationResult = await FirebaseMigrationHelper.validateMigration();
if (validationResult.isValid) {
  print('Migration validation passed');
} else {
  print('Migration validation issues: ${validationResult.issues}');
}
```

## Step 12: Update Riverpod Providers

Update providers to use Firebase streams instead of local database:

```dart
// Example: Update chat rooms provider
final chatRoomsProvider = StreamProvider<List<ChatRoom>>((ref) {
  final currentUser = ref.watch(authProvider).user;
  if (currentUser == null) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('chatRooms')
      .where('participantIds', arrayContains: currentUser.id)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatRoom.fromMap({...doc.data(), 'id': doc.id}))
          .toList());
});
```

## Step 13: Testing

### Test Authentication
1. Create test accounts
2. Verify email verification works
3. Test password reset

### Test Database Operations
1. Create test data
2. Verify real-time updates
3. Test security rules

### Test File Upload
1. Upload test images/documents
2. Verify storage permissions
3. Test file deletion

## Step 14: Production Deployment

### Update Security Rules
1. Review and tighten Firestore rules
2. Update Storage rules for production
3. Configure proper CORS settings

### Configure Environment
1. Set up production Firebase project
2. Update configuration files
3. Test in production environment

## Troubleshooting

### Common Issues
1. **Build errors**: Ensure all dependencies are compatible
2. **Authentication issues**: Check Firebase console settings
3. **Permission denied**: Review security rules
4. **File upload fails**: Check storage rules and CORS

### Debug Commands
```bash
# Check Firebase configuration
flutterfire configure

# Debug Firebase connection
flutter run --debug

# Check logs
flutter logs
```

## Security Considerations

1. **Never expose API keys** in client code
2. **Use security rules** to protect data
3. **Validate data** on both client and server
4. **Implement proper user roles** and permissions
5. **Regular security audits** of rules and permissions

## Performance Optimization

1. **Use indexes** for complex queries
2. **Implement pagination** for large datasets
3. **Cache frequently accessed data**
4. **Optimize image uploads** with compression
5. **Use Firebase Performance Monitoring**

## Monitoring and Analytics

1. **Set up Firebase Analytics** for user behavior
2. **Monitor Crashlytics** for error tracking
3. **Use Performance Monitoring** for app performance
4. **Set up alerts** for critical issues

---

## Next Steps After Firebase Setup

1. Test the complete user flow
2. Migrate existing data
3. Update UI to handle Firebase-specific features
4. Implement push notifications
5. Add offline support with Firestore caching
6. Set up CI/CD for automated deployments
