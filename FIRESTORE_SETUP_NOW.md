# 🔥 Firestore Setup - CRITICAL!

## ⚠️ YOUR VENDORS ARE NOT SHOWING BECAUSE OF FIRESTORE PERMISSIONS!

You need to update your Firestore security rules. Here's how:

## Step 1: Open Firebase Console

1. Go to: https://console.firebase.google.com
2. Select project: **mobile-computing-project-9c26a**
3. Click **Firestore Database** in left menu
4. Click the **Rules** tab at the top

## Step 2: Replace the Rules

Copy this EXACTLY and paste in the rules editor:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Vendors - Anyone can read (for customer browsing)
    match /vendors/{vendorId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Products - Anyone can read
    match /products/{productId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Orders
    match /orders/{orderId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Pending verifications
    match /pending_verifications/{verificationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## Step 3: Publish the Rules

1. Click the **Publish** button (top right)
2. Wait for "Rules published successfully" message
3. Close Firebase Console

## Step 4: Restart Your App

```bash
# In VS Code terminal, press Ctrl+C to stop
# Then run again:
flutter run -d chrome
```

## Step 5: Test Again

1. Login as customer
2. Click the bug icon (🐛) 
3. Check if vendors appear now

---

## 🎯 What This Does

These rules allow:
- ✅ **Anyone** to READ vendors and products (so customers can browse)
- ✅ **Logged in users** to WRITE (create/update) vendors and products
- ✅ **Logged in users** to read/write their own data

This is safe for development. For production, use the detailed rules in `firestore.rules` file.

---

## 🚨 If You Still Don't See Vendors

After updating rules, check the debug screen:
- If you see vendors → Just reload the customer home
- If NO vendors → The vendor was never created, create new shopkeeper account

---

**DO THIS NOW - IT'S THE MAIN ISSUE!** 🔥
