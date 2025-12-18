# SwatServe - Shamozai ki Pehli Delivery Service

![SwatServe](https://img.shields.io/badge/Flutter-3.0+-blue)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)
![License](https://img.shields.io/badge/License-MIT-green)

**SwatServe** is a modern, beautiful food and grocery delivery application specifically designed for Shamozai village in Swat Valley, Pakistan. The app features an elegant emerald green and teal gradient design inspired by the natural beauty of the valley.

## ✨ Features

### 🎯 Three User Roles

1. **Admin**
   - Verify shopkeeper licenses
   - Manage all vendors (max 40 shopkeepers)
   - View all orders and analytics
   - Create and manage promotional offers

2. **Shopkeeper**
   - Add, edit, and delete products
   - Manage inventory and stock
   - View and manage orders
   - Update shop information
   - License verification required

3. **Customer**
   - Browse vendors by category
   - Search for restaurants, shops, and items
   - Add items to cart
   - Multiple payment methods (COD, JazzCash, EasyPaisa)
   - Track orders
   - Rate and review vendors

### 🎨 Beautiful UI/UX

- Emerald green and teal gradient color scheme
- Mountain/valley themed imagery
- Smooth animations and transitions
- Modern card-based design
- Responsive layout
- Pakistani Rupee (Rs) currency

### 📦 Categories

- All
- Restaurants
- Grocery Stores
- Bakery
- Pharmacy
- Fresh Produce

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Firebase account
- Android Studio / VS Code
- Android Emulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   cd "d:\OneDrive\Desktop\village project"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   a. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

   b. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```

   c. Select your Firebase project or create a new one
   
   d. Enable the following Firebase services in Firebase Console:
      - Authentication (Email/Password)
      - Cloud Firestore
      - Firebase Storage

4. **Set up Firestore Security Rules**

   Go to Firebase Console > Firestore Database > Rules and add:

   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId || 
                        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
       
       // Vendors collection
       match /vendors/{vendorId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'shopkeeper');
       }
       
       // Products collection
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null && 
                        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'shopkeeper');
       }
       
       // Orders collection
       match /orders/{orderId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null && 
                         (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin' ||
                          get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'shopkeeper');
       }
       
       // Pending verifications (admin only)
       match /pending_verifications/{verificationId} {
         allow read, write: if request.auth != null && 
                              get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
       }
     }
   }
   ```

5. **Create an admin user**

   First, run the app and create a regular customer account. Then manually update the user in Firestore:
   
   - Go to Firebase Console > Firestore Database
   - Find your user document in the `users` collection
   - Change the `role` field to `"admin"`

6. **Add sample data (optional)**

   You can add sample vendors and products through the admin panel after creating an admin account.

### Running the App

```bash
# Check for connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release
```

## 📱 App Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration
├── models/                        # Data models
│   ├── user_model.dart
│   ├── vendor_model.dart
│   ├── product_model.dart
│   ├── cart_item.dart
│   └── order_model.dart
├── providers/                     # State management
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   ├── vendor_provider.dart
│   └── order_provider.dart
├── screens/                       # UI screens
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── customer/
│   │   ├── customer_home_screen.dart
│   │   ├── vendor_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── checkout_screen.dart
│   │   ├── order_success_screen.dart
│   │   ├── orders_screen.dart
│   │   └── profile_screen.dart
│   ├── shopkeeper/
│   │   └── shopkeeper_dashboard_screen.dart
│   └── admin/
│       └── admin_dashboard_screen.dart
├── widgets/                       # Reusable widgets
│   └── vendor_card.dart
└── utils/                         # Utilities
    ├── app_theme.dart
    └── app_constants.dart
```

## 🔐 User Accounts

### Creating Accounts

1. **Customer**: Open the app → Sign Up → Select "Customer" → Fill details → Sign Up
2. **Shopkeeper**: Open the app → Sign Up → Select "Shopkeeper" → Fill details + License Number → Wait for admin verification
3. **Admin**: Create as customer first, then manually change role in Firestore



## 🎨 Customization

### Colors

Edit `lib/utils/app_theme.dart` to customize the color scheme:

```dart
static const Color primaryColor = Color(0xFF10B981); // Emerald Green
static const Color secondaryColor = Color(0xFF14B8A6); // Teal
```

### App Name & Tagline

Edit `lib/utils/app_constants.dart`:

```dart
static const String appName = 'SwatServe';
static const String appTagline = 'Shamozai ki Pehli Delivery Service';
```

### Business Rules

Modify in `lib/utils/app_constants.dart`:

```dart
static const int maxShopkeepers = 40;
static const double deliveryFee = 50.0;
static const double freeDeliveryThreshold = 500.0;
```

## 📊 Firebase Collections Structure

### users
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "3001234567",
  "role": "customer|shopkeeper|admin",
  "addresses": [],
  "shopId": "optional_vendor_id",
  "isVerified": true,
  "createdAt": "timestamp",
  "profileImage": "optional_url"
}
```

### vendors
```json
{
  "name": "Swat Karahi House",
  "category": "Restaurants",
  "description": "Traditional Pakistani food",
  "ownerId": "user_id",
  "imageUrl": "url",
  "rating": 4.5,
  "totalReviews": 120,
  "deliveryTime": "25-35 min",
  "minimumOrder": 200,
  "isOpen": true,
  "isFeatured": false,
  "offers": ["20% OFF", "Free Delivery"],
  "phone": "03001234567",
  "address": "Main Bazaar, Shamozai",
  "createdAt": "timestamp"
}
```

### products
```json
{
  "vendorId": "vendor_id",
  "name": "Mutton Karahi",
  "description": "Delicious mutton karahi",
  "price": 1200,
  "imageUrl": "url",
  "category": "Main Course",
  "isAvailable": true,
  "isFeatured": true,
  "stock": 100,
  "createdAt": "timestamp"
}
```

### orders
```json
{
  "userId": "user_id",
  "userName": "John Doe",
  "userPhone": "3001234567",
  "items": [],
  "subtotal": 1500,
  "deliveryFee": 50,
  "totalAmount": 1550,
  "deliveryAddress": "House 123, Shamozai",
  "deliveryInstructions": "Call when you arrive",
  "paymentMethod": "Cash on Delivery",
  "status": "pending",
  "createdAt": "timestamp",
  "deliveredAt": "optional_timestamp"
}
```

## 🛠️ Development

### Adding New Features

1. Create model in `lib/models/`
2. Add provider in `lib/providers/`
3. Create screens in `lib/screens/`
4. Update routes in `main.dart`

### Testing

```bash
flutter test
```

### Building for Production

**Android:**
```bash
flutter build apk --release
# Or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📝 TODO

- [ ] Implement real-time order tracking
- [ ] Add push notifications
- [ ] Integrate JazzCash payment gateway
- [ ] Integrate EasyPaisa payment gateway
- [ ] Add rating and review system
- [ ] Implement search with filters
- [ ] Add promo code functionality
- [ ] Create admin analytics dashboard
- [ ] Add Urdu language support
- [ ] Implement chat support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Support

For support, email support@swatserve.com or open an issue in the repository.

## 🌟 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The Shamozai community

---

**Made with ❤️ for Shamozai, Swat Valley, Pakistan**
# SwatServe
