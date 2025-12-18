import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_theme.dart';
import 'manage_users_screen.dart';
import 'all_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardCard(
            context,
            'Manage Users',
            Icons.people,
            AppTheme.primaryColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ManageUsersScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'All Orders',
            Icons.receipt_long,
            Colors.blue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AllOrdersScreen()),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Shopkeepers',
            Icons.store,
            Colors.orange,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageUsersScreen(),
                ),
              );
            },
          ),
          _buildDashboardCard(
            context,
            'Analytics',
            Icons.analytics,
            Colors.purple,
            () {
              _showAnalytics(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAnalytics(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;

    // Get counts
    final usersSnapshot = await firestore.collection('users').get();
    final ordersSnapshot = await firestore.collection('orders').get();
    final vendorsSnapshot = await firestore.collection('vendors').get();

    final totalUsers = usersSnapshot.docs.length;
    final totalOrders = ordersSnapshot.docs.length;
    final totalVendors = vendorsSnapshot.docs.length;

    final shopkeepers = usersSnapshot.docs
        .where((doc) => doc.data()['role'] == 'shopkeeper')
        .length;
    final customers = usersSnapshot.docs
        .where((doc) => doc.data()['role'] == 'customer')
        .length;

    double totalRevenue = 0;
    for (var order in ordersSnapshot.docs) {
      totalRevenue += (order.data()['totalAmount'] as num).toDouble();
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Analytics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticRow(
                  'Total Users', totalUsers.toString(), Icons.people),
              _buildAnalyticRow(
                  'Customers', customers.toString(), Icons.person),
              _buildAnalyticRow(
                  'Shopkeepers', shopkeepers.toString(), Icons.store),
              _buildAnalyticRow(
                  'Total Vendors', totalVendors.toString(), Icons.restaurant),
              _buildAnalyticRow(
                  'Total Orders', totalOrders.toString(), Icons.receipt),
              _buildAnalyticRow(
                  'Total Revenue',
                  'Rs ${totalRevenue.toStringAsFixed(0)}',
                  Icons.monetization_on),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
