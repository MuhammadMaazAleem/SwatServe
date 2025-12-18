# SwatServe Setup Guide

## Complete Setup Instructions

### Step 1: Install Flutter Dependencies

Open a terminal in your project directory and run:

```bash
flutter pub get
```

### Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 3: Configure Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Run the FlutterFire configuration:

```bash
flutterfire configure
```

Follow the prompts to:
- Select your Firebase project
- Choose platforms (Android, iOS, Web)
- This will generate `firebase_options.dart`

### Step 4: Enable Firebase Services

In Firebase Console, enable:

1. **Authentication**
   - Go to Authentication > Sign-in method
   - Enable "Email/Password"

2. **Cloud Firestore**
   - Go to Firestore Database
   - Create database in production mode
   - Add the security rules from README.md

3. **Firebase Storage**
   - Go to Storage
   - Get started
   - Keep default security rules

### Step 5: Create Admin Account

1. Run the app:
   ```bash
   flutter run
   ```

2. Sign up as a customer with:
   - Email: admin@swatserve.com
   - Password: admin123
   - Name: Admin User
   - Phone: 3001234567

3. Go to Firebase Console > Firestore
4. Find the user in `users` collection
5. Edit the document and change `role` to `"admin"`

### Step 6: Add Sample Data (Optional)

You can add sample vendors through the admin panel, or manually in Firestore:

**Sample Vendor:**
```json
{
  "name": "Swat Karahi House",
  "category": "Restaurants",
  "description": "Traditional Pakistani cuisine from Swat Valley",
  "ownerId": "your_shopkeeper_user_id",
  "imageUrl": "",
  "rating": 4.5,
  "totalReviews": 0,
  "deliveryTime": "25-35 min",
  "minimumOrder": 200,
  "isOpen": true,
  "isFeatured": true,
  "offers": ["20% OFF", "Free Delivery"],
  "phone": "03001234567",
  "address": "Main Bazaar, Shamozai, Swat",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

**Sample Product:**
```json
{
  "vendorId": "vendor_id_from_above",
  "name": "Mutton Karahi",
  "description": "Traditional mutton karahi cooked with fresh spices",
  "price": 1200,
  "imageUrl": "",
  "category": "Main Course",
  "isAvailable": true,
  "isFeatured": true,
  "stock": 100,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### Step 7: Test the App

1. **Test as Customer:**
   - Browse vendors
   - Add items to cart
   - Place an order

2. **Test as Shopkeeper:**
   - Create a shopkeeper account
   - Login as admin and verify the shopkeeper
   - Login as shopkeeper and add products

3. **Test as Admin:**
   - Login with admin account
   - Verify pending shopkeepers
   - View all orders

## Troubleshooting

### Firebase Configuration Issues

If you see "Firebase not configured" errors:
1. Make sure `firebase_options.dart` exists
2. Run `flutterfire configure` again
3. Restart the app

### Package Version Conflicts

If you get dependency errors:
```bash
flutter pub upgrade
flutter clean
flutter pub get
```

### Android Build Issues

If Android build fails:
1. Make sure you have Android Studio installed
2. Accept Android licenses:
   ```bash
   flutter doctor --android-licenses
   ```
3. Update Android SDK

### iOS Build Issues

If iOS build fails:
1. Run from `ios/` folder:
   ```bash
   cd ios
   pod install
   cd ..
   ```
2. Open Xcode and update signing

## Next Steps

1. **Customize Colors**: Edit `lib/utils/app_theme.dart`
2. **Add Logo**: Replace icons in `assets/images/`
3. **Configure Payment**: Integrate JazzCash/EasyPaisa APIs
4. **Add Push Notifications**: Set up FCM
5. **Deploy to Stores**: Build release versions

## Support

For issues, check:
- Flutter documentation: https://flutter.dev/docs
- Firebase documentation: https://firebase.google.com/docs
- GitHub issues: (your repository)

---

Happy coding! 🚀
