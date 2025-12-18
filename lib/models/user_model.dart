import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // admin, shopkeeper, customer
  final List<String> addresses;
  final String? shopId; // For shopkeepers
  final bool isVerified; // For shopkeepers - license verification
  final DateTime createdAt;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.addresses = const [],
    this.shopId,
    this.isVerified = false,
    required this.createdAt,
    this.profileImage,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle createdAt field - it might be Timestamp, String, or null
    DateTime createdAtDate;
    if (data['createdAt'] is Timestamp) {
      createdAtDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAtDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      addresses: List<String>.from(data['addresses'] ?? []),
      shopId: data['shopId'],
      isVerified: data['isVerified'] ?? false,
      createdAt: createdAtDate,
      profileImage: data['profileImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'addresses': addresses,
      'shopId': shopId,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImage': profileImage,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    List<String>? addresses,
    String? shopId,
    bool? isVerified,
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      addresses: addresses ?? this.addresses,
      shopId: shopId ?? this.shopId,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
