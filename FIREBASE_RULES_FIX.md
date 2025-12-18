# Firebase Setup Instructions

## ⚠️ CRITICAL: Update Firestore Security Rules

You're getting **permission-denied** errors because Firestore rules are too restrictive.

### Step 1: Go to Firebase Console

1. Open: https://console.firebase.google.com/project/mobile-computing-project-9c26a/firestore
2. Click the **"Rules"** tab at the top
3. **Delete all existing rules**
4. **Paste the rules below**
5. Click **"Publish"**

### Step 2: Paste These Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - allow read for authenticated, write for own document
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && (
        request.auth.uid == userId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
      );
      allow delete: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Vendors collection - read for all authenticated, write for authenticated users
    match /vendors/{vendorId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Products collection - read for all authenticated, write for authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Orders collection - read/write for authenticated users
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Pending verifications - admin only
    match /pending_verifications/{docId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### Step 3: Enable Authentication

1. Go to: https://console.firebase.google.com/project/mobile-computing-project-9c26a/authentication
2. Click **"Get started"** (if not already done)
3. Click **"Sign-in method"** tab
4. Enable **"Email/Password"** provider
5. Toggle it **ON**
6. Click **"Save"**

### Step 4: Test the App

1. **Refresh the Chrome window** with your app
2. Try signing up with a new account
3. The permission error should be gone!

### Credentials to Login:

**Admin Account:**
- Email: admin@swatserve.com
- Password: admin123

**Or create a new account** - signup should now work!

---

## What's Fixed:

✅ Firestore rules now allow signup
✅ Edit Profile screen added
✅ Logout button improved with confirmation
✅ Profile data can be updated

## Next Steps:

After updating the rules, you should be able to:
1. Sign up new users (Customer/Shopkeeper)
2. Edit your profile
3. Logout and login
4. Admin can manage all users
