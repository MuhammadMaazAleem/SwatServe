import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  String _selectedPayment = AppConstants.paymentCOD;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final order = OrderModel(
      id: '',
      userId: authProvider.currentUser!.id,
      userName: authProvider.currentUser!.name,
      userPhone: authProvider.currentUser!.phone,
      items: cartProvider.cartItems,
      subtotal: cartProvider.subtotal,
      deliveryFee: cartProvider.deliveryFee,
      totalAmount: cartProvider.totalAmount,
      deliveryAddress: _addressController.text,
      deliveryInstructions: _instructionsController.text,
      paymentMethod: _selectedPayment,
      createdAt: DateTime.now(),
    );

    final orderId = await orderProvider.createOrder(order);

    setState(() => _isLoading = false);

    if (orderId != null && mounted) {
      cartProvider.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: orderId),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('Delivery Address'),
            TextFormField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter your complete address in Shamozai',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter delivery address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Delivery Instructions (Optional)'),
            TextFormField(
              controller: _instructionsController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'e.g., Call when you arrive',
                prefixIcon: Icon(Icons.note),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Payment Method'),
            _buildPaymentOption(AppConstants.paymentCOD, Icons.money, true),
            _buildPaymentOption(
                AppConstants.paymentJazzCash, Icons.payment, false),
            _buildPaymentOption(AppConstants.paymentEasyPaisa,
                Icons.account_balance_wallet, false),
            const SizedBox(height: 24),
            _buildOrderSummary(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _placeOrder,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Place Order', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String method, IconData icon, bool isActive) {
    final isSelected = _selectedPayment == method;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(method),
        trailing: isActive
            ? Radio<String>(
                value: method,
                groupValue: _selectedPayment,
                onChanged: (value) {
                  setState(() => _selectedPayment = value!);
                },
              )
            : const Chip(
                label: Text('Coming Soon', style: TextStyle(fontSize: 10)),
                backgroundColor: AppTheme.backgroundColor,
              ),
        tileColor: isSelected ? AppTheme.backgroundColor : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
        ),
        onTap:
            isActive ? () => setState(() => _selectedPayment = method) : null,
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Items', '${cartProvider.totalItems}'),
              _buildSummaryRow('Subtotal',
                  '${AppConstants.currency} ${cartProvider.subtotal.toStringAsFixed(0)}'),
              _buildSummaryRow('Delivery Fee',
                  '${AppConstants.currency} ${cartProvider.deliveryFee.toStringAsFixed(0)}'),
              const Divider(),
              _buildSummaryRow(
                'Total',
                '${AppConstants.currency} ${cartProvider.totalAmount.toStringAsFixed(0)}',
                isTotal: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 18 : 14,
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
