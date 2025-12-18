import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.currentUser?.shopId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: shopId == null
          ? const Center(child: Text('No shop assigned to your account'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('vendorId', isEqualTo: shopId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data?.docs ?? [];

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('No products yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Tap + to add your first product'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final doc = products[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: data['imageUrl'] != null
                                ? Image.network(data['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.fastfood))
                                : const Icon(Icons.fastfood,
                                    color: AppTheme.primaryColor),
                          ),
                        ),
                        title: Text(data['name'] ?? 'Unknown',
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Rs ${data['price']?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                'Stock: ${data['stock'] ?? 0} | ${data['isAvailable'] == true ? 'Available' : 'Out of Stock'}'),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: const Text('Edit'),
                              onTap: () => Future.delayed(
                                Duration.zero,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddProductScreen(
                                      productId: doc.id,
                                      productData: data,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              child: const Text('Toggle Availability'),
                              onTap: () => _toggleAvailability(
                                  doc.id, data['isAvailable'] ?? true),
                            ),
                            PopupMenuItem(
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () => Future.delayed(
                                Duration.zero,
                                () => _deleteProduct(
                                    context, doc.id, data['name']),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  void _toggleAvailability(String productId, bool currentStatus) {
    FirebaseFirestore.instance.collection('products').doc(productId).update({
      'isAvailable': !currentStatus,
    });
  }

  Future<void> _deleteProduct(
      BuildContext context, String productId, String productName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$productName deleted')),
        );
      }
    }
  }
}
