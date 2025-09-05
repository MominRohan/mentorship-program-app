# Firebase Database Structure for Mentoring App

## Firestore Collections Structure

### 1. Users Collection (`/users/{userId}`)
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "address": "123 Main St, City, Country",
  "bio": "Experienced software developer...",
  "occupation": "Software Engineer",
  "expertise": "Flutter, Firebase, Mobile Development",
  "role": "user", // "user", "mentor", "admin", "superAdmin"
  "verificationStatus": "pending", // "pending", "inReview", "verified", "rejected", "suspended"
  "createdAt": 1640995200000,
  "updatedAt": 1640995200000,
  "lastLoginAt": 1640995200000,
  "avatarUrl": "https://storage.googleapis.com/...",
  "verificationDocuments": {
    "identity": {
      "id": "doc_123",
      "type": "identity",
      "fileName": "passport.pdf",
      "fileUrl": "https://storage.googleapis.com/...",
      "status": "pending",
      "uploadedAt": 1640995200000,
      "reviewedBy": null,
      "reviewedAt": null,
      "reviewNotes": null
    }
  },
  "isActive": true,
  "isEmailVerified": true,
  "isPhoneVerified": false,
  "fcmToken": "firebase_messaging_token"
}
```

### 2. Mentors Collection (`/mentors/{mentorId}`)
```json
{
  "userId": "user_123", // Reference to users collection
  "specializations": ["Mobile Development", "UI/UX Design"],
  "experience": "5+ years",
  "rating": 4.8,
  "totalSessions": 150,
  "completedSessions": 145,
  "availability": {
    "monday": ["09:00", "17:00"],
    "tuesday": ["09:00", "17:00"],
    "wednesday": ["09:00", "17:00"]
  },
  "hourlyRate": 50,
  "languages": ["English", "Spanish"],
  "certifications": [
    {
      "name": "Google Flutter Certified",
      "issuer": "Google",
      "date": "2023-01-15",
      "url": "https://..."
    }
  ],
  "isAvailable": true,
  "mentorSince": 1640995200000
}
```

### 3. Admins Collection (`/admins/{adminId}`)
```json
{
  "userId": "user_456", // Reference to users collection
  "permissions": [
    "manage_users",
    "verify_mentors",
    "manage_sessions",
    "view_analytics"
  ],
  "department": "User Management",
  "assignedAt": 1640995200000,
  "assignedBy": "superadmin_123"
}
```

### 4. Chat Rooms Collection (`/chatRooms/{chatRoomId}`)
```json
{
  "name": "John & Sarah",
  "description": "One-on-one mentoring chat",
  "type": "oneOnOne", // "oneOnOne", "group"
  "participantIds": ["user_123", "mentor_456"],
  "lastMessage": "Thanks for the session!",
  "lastMessageTime": 1640995200000,
  "lastMessageSenderId": "user_123",
  "createdAt": 1640995200000,
  "updatedAt": 1640995200000,
  "imageUrl": null,
  "isActive": true,
  "unreadCounts": {
    "user_123": 0,
    "mentor_456": 2
  }
}
```

### 5. Messages Collection (`/chatRooms/{chatRoomId}/messages/{messageId}`)
```json
{
  "senderId": "user_123",
  "senderName": "John Doe",
  "senderAvatarUrl": "https://...",
  "content": "Hello, I need help with Flutter",
  "type": "text", // "text", "image", "video", "audio", "document", "location"
  "timestamp": 1640995200000,
  "status": "read", // "sending", "sent", "delivered", "read", "failed"
  "replyToMessageId": null,
  "attachments": [
    {
      "id": "att_123",
      "fileName": "screenshot.png",
      "fileUrl": "https://storage.googleapis.com/...",
      "type": "image",
      "fileSize": 1024000,
      "mimeType": "image/png",
      "thumbnailUrl": "https://..."
    }
  ],
  "metadata": {},
  "editedAt": null,
  "isDeleted": false
}
```

### 6. Sessions Collection (`/sessions/{sessionId}`)
```json
{
  "menteeId": "user_123",
  "mentorId": "mentor_456",
  "title": "Flutter Development Session",
  "description": "Learning state management",
  "scheduledAt": 1640995200000,
  "duration": 60, // minutes
  "status": "completed", // "pending", "approved", "in_progress", "completed", "cancelled"
  "questions": "How to implement Riverpod?",
  "meetingUrl": "https://meet.google.com/...",
  "notes": "Covered Provider pattern and Riverpod basics",
  "rating": 5,
  "feedback": "Excellent session!",
  "createdAt": 1640995200000,
  "updatedAt": 1640995200000
}
```

### 7. Verification Requests Collection (`/verificationRequests/{requestId}`)
```json
{
  "userId": "user_123",
  "requestType": "mentor_verification",
  "documents": [
    {
      "type": "identity",
      "fileName": "passport.pdf",
      "fileUrl": "https://storage.googleapis.com/..."
    },
    {
      "type": "education",
      "fileName": "degree.pdf",
      "fileUrl": "https://storage.googleapis.com/..."
    }
  ],
  "status": "pending", // "pending", "in_review", "approved", "rejected"
  "submittedAt": 1640995200000,
  "reviewedBy": null,
  "reviewedAt": null,
  "reviewNotes": null
}
```

## Firebase Realtime Database Structure (for real-time features)

### 1. User Presence (`/presence/{userId}`)
```json
{
  "isOnline": true,
  "lastSeen": 1640995200000,
  "currentActivity": "chatting" // "idle", "chatting", "in_session"
}
```

### 2. Typing Indicators (`/typing/{chatRoomId}/{userId}`)
```json
{
  "isTyping": true,
  "timestamp": 1640995200000
}
```

### 3. Live Sessions (`/liveSessions/{sessionId}`)
```json
{
  "participants": {
    "mentor_456": {
      "joinedAt": 1640995200000,
      "isPresent": true
    },
    "user_123": {
      "joinedAt": 1640995200000,
      "isPresent": true
    }
  },
  "status": "active",
  "startedAt": 1640995200000
}
```

## Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
        (resource.data.role == 'mentor' || resource.data.role == 'admin');
    }
    
    // Mentors collection
    match /mentors/{mentorId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Chat rooms
    match /chatRooms/{chatRoomId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participantIds;
    }
    
    // Messages
    match /chatRooms/{chatRoomId}/messages/{messageId} {
      allow read: if request.auth != null && 
        request.auth.uid in get(/databases/$(database)/documents/chatRooms/$(chatRoomId)).data.participantIds;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.senderId;
    }
    
    // Admin-only collections
    match /admins/{adminId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'superAdmin'];
    }
  }
}
```

### Realtime Database Security Rules
```json
{
  "rules": {
    "presence": {
      "$userId": {
        ".read": true,
        ".write": "$userId === auth.uid"
      }
    },
    "typing": {
      "$chatRoomId": {
        "$userId": {
          ".read": true,
          ".write": "$userId === auth.uid"
        }
      }
    }
  }
}
```

## Storage Structure

### Firebase Storage
```
/users/{userId}/
  - avatar.jpg
  - documents/
    - identity/
      - passport.pdf
    - education/
      - degree.pdf
    - experience/
      - certificate.pdf

/chat_attachments/{chatRoomId}/
  - images/
    - {messageId}_image.jpg
  - documents/
    - {messageId}_document.pdf
  - videos/
    - {messageId}_video.mp4

/session_materials/{sessionId}/
  - notes.pdf
  - recordings/
    - session_recording.mp4
```
