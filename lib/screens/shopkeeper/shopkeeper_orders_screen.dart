import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../models/order_model.dart';

class ShopkeeperOrdersScreen extends StatelessWidget {
  const ShopkeeperOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.currentUser?.shopId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: shopId == null
          ? const Center(child: Text('No shop assigned'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allOrders = snapshot.data?.docs ?? [];

                // Filter orders that contain products from this shop
                final myOrders = allOrders.where((doc) {
                  final order = OrderModel.fromFirestore(doc);
                  return order.items.any((item) => item.vendorId == shopId);
                }).toList();

                if (myOrders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 100, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No orders yet', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: myOrders.length,
                  itemBuilder: (context, index) {
                    final doc = myOrders[index];
                    final order = OrderModel.fromFirestore(doc);

                    // Get only items from this shop
                    final myItems = order.items
                        .where((item) => item.vendorId == shopId)
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(order.status),
                          child: Text('${myItems.length}',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order.userName),
                            Text(
                                DateFormat('MMM dd, hh:mm a')
                                    .format(order.createdAt),
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: Chip(
                          label: Text(order.status.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.white)),
                          backgroundColor: _getStatusColor(order.status),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Items:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                ...myItems.map((item) => Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              child: Text(
                                                  '${item.quantity}x ${item.name}')),
                                          Text(
                                              'Rs ${item.totalPrice.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    )),
                                const Divider(height: 24),
                                Text('Customer: ${order.userName}'),
                                Text('Phone: ${order.userPhone}'),
                                Text('Address: ${order.deliveryAddress}'),
                                Text('Payment: ${order.paymentMethod}'),
                                const SizedBox(height: 16),
                                const Text('Update Status:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    _buildStatusChip(
                                        'confirmed', doc.id, order.status),
                                    _buildStatusChip(
                                        'preparing', doc.id, order.status),
                                    _buildStatusChip('out_for_delivery', doc.id,
                                        order.status),
                                    _buildStatusChip(
                                        'delivered', doc.id, order.status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildStatusChip(String status, String orderId, String currentStatus) {
    final isSelected = status == currentStatus;
    return ChoiceChip(
      label: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
            fontSize: 10, color: isSelected ? Colors.white : Colors.black),
      ),
      selected: isSelected,
      selectedColor: _getStatusColor(status),
      onSelected: (selected) {
        if (selected) {
          FirebaseFirestore.instance.collection('orders').doc(orderId).update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'out_for_delivery':
        return AppTheme.primaryColor;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
