# Firebase Setup Guide

## Current Status: COMMENTED OUT FOR DEVELOPMENT

All Firebase functionality is currently commented out to allow development without Firebase configuration. The app uses simulation code for testing the verification UI.

## When Ready to Enable Firebase:

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication
4. Enable Phone and Email sign-in methods

### 4. Configure Flutter App
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter app
flutterfire configure
```

### 5. Uncomment Dependencies in pubspec.yaml
```yaml
dependencies:
  # Uncomment these lines:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
```

### 6. Update firebase_options.dart
Replace placeholder values with your actual Firebase configuration from the FlutterFire CLI output.

### 7. Uncomment Firebase Code
1. **main.dart**: Uncomment Firebase initialization
2. **firebase_auth_service.dart**: Uncomment all Firebase imports and implementations
3. Remove simulation code

### 8. Test Firebase Integration
- Run `flutter pub get`
- Test phone verification with a real phone number
- Test email verification with a real email

## Files Modified for Firebase:
- ✅ `pubspec.yaml` - Dependencies added (commented)
- ✅ `lib/main.dart` - Firebase initialization (commented)
- ✅ `lib/firebase_options.dart` - Configuration file (placeholder)
- ✅ `lib/services/firebase_auth_service.dart` - Auth service (simulation mode)
- ✅ `lib/screens/verification_method_screen.dart` - UI ready
- ✅ `lib/screens/otp_verification_screen.dart` - UI ready

## Current Simulation Behavior:
- **Phone verification**: Always sends "code sent" message
- **OTP verification**: Accepts "123456" as valid code
- **Email verification**: Always shows "email sent" message
- **Email checking**: Simulates verification after ~5 seconds

## Production Notes:
- Phone verification requires real phone numbers in production
- Email verification requires proper SMTP configuration
- Test with Firebase Auth emulator for development
- Configure proper error handling for production use
