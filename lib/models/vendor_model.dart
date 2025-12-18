import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String ownerId; // User ID of shopkeeper
  final String imageUrl;
  final double rating;
  final int totalReviews;
  final String deliveryTime; // e.g., "25-35 min"
  final double minimumOrder;
  final bool isOpen;
  final bool isFeatured;
  final List<String> offers; // e.g., ["20% OFF", "Free Delivery"]
  final String phone;
  final String address;
  final DateTime createdAt;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.ownerId,
    required this.imageUrl,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.deliveryTime,
    required this.minimumOrder,
    this.isOpen = true,
    this.isFeatured = false,
    this.offers = const [],
    required this.phone,
    required this.address,
    required this.createdAt,
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle timestamp field safely
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        createdAt = DateTime.parse(data['createdAt']);
      }
    }
    
    return VendorModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      deliveryTime: data['deliveryTime'] ?? '30-40 min',
      minimumOrder: (data['minimumOrder'] ?? 0.0).toDouble(),
      isOpen: data['isOpen'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      offers: List<String>.from(data['offers'] ?? []),
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'ownerId': ownerId,
      'imageUrl': imageUrl,
      'rating': rating,
      'totalReviews': totalReviews,
      'deliveryTime': deliveryTime,
      'minimumOrder': minimumOrder,
      'isOpen': isOpen,
      'isFeatured': isFeatured,
      'offers': offers,
      'phone': phone,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
