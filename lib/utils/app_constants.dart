class AppConstants {
  // App Info
  static const String appName = 'SwatServe';
  static const String appTagline = 'Shamozai ki Pehli Delivery Service';
  static const String location = 'Shamozai, Swat Valley, Pakistan';
  static const String currency = 'Rs';
  static const String phoneCode = '+92';

  // Business Rules
  static const int maxShopkeepers = 40;
  static const double deliveryFee = 50.0;
  static const double freeDeliveryThreshold = 500.0;
  static const int estimatedDeliveryMinutes = 30;

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleShopkeeper = 'shopkeeper';
  static const String roleCustomer = 'customer';

  // Categories for filtering (customer view)
  static const List<String> vendorCategories = [
    'All',
    'Restaurants',
    'Grocery Stores',
    'Bakery',
    'Pharmacy',
    'Fresh Produce',
  ];

  // Categories for shop setup (shopkeeper)
  static const List<String> shopCategories = [
    'General',
    'Restaurants',
    'Grocery Stores',
    'Bakery',
    'Pharmacy',
    'Fresh Produce',
    'Beverages',
    'Dairy & Eggs',
  ];

  // Payment Methods
  static const String paymentCOD = 'Cash on Delivery';
  static const String paymentJazzCash = 'JazzCash';
  static const String paymentEasyPaisa = 'EasyPaisa';
  static const String paymentBankTransfer = 'Bank Transfer';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderPreparing = 'preparing';
  static const String orderOutForDelivery = 'out_for_delivery';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String vendorsCollection = 'vendors';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String promosCollection = 'promos';

  // Validation
  static const int minPasswordLength = 6;
  static const int minPhoneLength = 10;

  // UI
  static const double defaultPadding = 16.0;
  static const double cardElevation = 2.0;
  static const double iconSize = 24.0;
}
