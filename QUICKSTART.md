# 🚀 Quick Start Guide - SwatServe

## For Developers (First Time Setup)

### 1. Open Terminal in Project Folder

```bash
cd "d:\OneDrive\Desktop\village project"
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

When prompted:
- Select or create a Firebase project
- Choose Android and/or iOS platforms
- This creates `firebase_options.dart` automatically

### 4. Setup Firebase Console

Go to https://console.firebase.google.com

**Enable Authentication:**
- Authentication → Sign-in method → Email/Password → Enable

**Create Firestore Database:**
- Firestore Database → Create database → Start in production mode
- Add security rules from README.md

**Enable Storage:**
- Storage → Get started → Use default rules

### 5. Run the App

```bash
flutter run
```

Select your device when prompted (emulator or physical device)

### 6. Create Admin Account

1. App opens → Click "Sign Up"
2. Fill in details:
   - Name: Admin
   - Email: admin@swatserve.com
   - Password: admin123
   - Phone: 3001234567
   - Role: Customer (we'll change this)

3. Go to Firebase Console → Firestore
4. Open `users` collection → Find your user
5. Edit → Change `role` from `"customer"` to `"admin"` → Save

6. Logout and login again as admin

## For Testing (Quick Access)

### Test Accounts

Create these accounts for testing:

**Admin:**
- Email: admin@swatserve.com
- Password: admin123

**Shopkeeper:**
- Email: shop@swatserve.com
- Password: shop123
- License: ABC123

**Customer:**
- Email: customer@swatserve.com
- Password: customer123

### User Flows to Test

**As Customer:**
1. Browse vendors by category
2. Search for items
3. Add items to cart
4. Checkout with COD
5. View order history

**As Shopkeeper:**
1. Login (after admin verification)
2. View dashboard
3. Add new products
4. Manage inventory
5. View orders

**As Admin:**
1. Login
2. Verify pending shopkeepers
3. Manage all vendors
4. View all orders
5. Create promotions

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Clean project
flutter clean

# Check Flutter installation
flutter doctor

# View devices
flutter devices
```

## File Structure Overview

```
lib/
├── main.dart                  → App entry point
├── screens/                   → All UI screens
│   ├── auth/                 → Login, Signup
│   ├── customer/             → Customer app
│   ├── shopkeeper/           → Shopkeeper dashboard
│   └── admin/                → Admin panel
├── providers/                 → State management
├── models/                    → Data models
├── widgets/                   → Reusable widgets
└── utils/                     → Theme, constants
```

## Troubleshooting

**App won't run?**
```bash
flutter clean
flutter pub get
flutter run
```

**Firebase errors?**
- Run `flutterfire configure` again
- Check Firebase Console settings

**Build errors?**
```bash
flutter doctor
# Fix any issues shown
```

## Key Features to Showcase

✅ Beautiful gradient UI (emerald green & teal)
✅ Three user role system
✅ Real-time cart updates
✅ Order placement & tracking
✅ Firebase authentication
✅ Category-based browsing
✅ Search functionality
✅ License verification system
✅ Max 40 shopkeeper limit

## Need Help?

1. Check [README.md](README.md) - Detailed documentation
2. Check [SETUP.md](SETUP.md) - Complete setup guide
3. Check Flutter docs - https://flutter.dev

---

**🎉 You're ready to go! Start the app and explore SwatServe!**
