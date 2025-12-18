import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final String paymentMethod;
  final String
      status; // pending, confirmed, preparing, out_for_delivery, delivered, cancelled
  final DateTime createdAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle createdAt field
    DateTime createdAtDate;
    if (data['createdAt'] is Timestamp) {
      createdAtDate = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] is String) {
      createdAtDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
    } else {
      createdAtDate = DateTime.now();
    }

    // Handle deliveredAt field
    DateTime? deliveredAtDate;
    if (data['deliveredAt'] != null) {
      if (data['deliveredAt'] is Timestamp) {
        deliveredAtDate = (data['deliveredAt'] as Timestamp).toDate();
      } else if (data['deliveredAt'] is String) {
        deliveredAtDate = DateTime.tryParse(data['deliveredAt']);
      }
    }

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryInstructions: data['deliveryInstructions'],
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: createdAtDate,
      deliveredAt: deliveredAtDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }

  // Get unique vendors from order
  Set<String> get vendorIds {
    return items.map((item) => item.vendorId).toSet();
  }
}
