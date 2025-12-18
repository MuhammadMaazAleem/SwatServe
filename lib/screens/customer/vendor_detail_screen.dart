import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/vendor_model.dart';
import '../../models/product_model.dart';
import '../../models/cart_item.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class VendorDetailScreen extends StatefulWidget {
  final VendorModel vendor;

  const VendorDetailScreen({super.key, required this.vendor});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VendorProvider>(context, listen: false)
          .loadProductsByVendor(widget.vendor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildVendorInfo()),
          _buildProductList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.cardGradient,
          ),
          child: Center(
            child: Icon(
              Icons.store,
              size: 80,
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVendorInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.vendor.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.vendor.isOpen
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.vendor.isOpen ? 'OPEN' : 'CLOSED',
                  style: TextStyle(
                    color: widget.vendor.isOpen
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.vendor.description,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(Icons.star, '${widget.vendor.rating}'),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.access_time, widget.vendor.deliveryTime),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.money,
                  'Min ${AppConstants.currency} ${widget.vendor.minimumOrder}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return Consumer<VendorProvider>(
      builder: (context, vendorProvider, _) {
        if (vendorProvider.isLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (vendorProvider.products.isEmpty) {
          return const SliverFillRemaining(
            child: Center(child: Text('No products available')),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = vendorProvider.products[index];
                return _buildProductCard(product);
              },
              childCount: vendorProvider.products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final inCart = cartProvider.hasItem(product.id);
        final quantity = cartProvider.getItemQuantity(product.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.fastfood, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!inCart)
                IconButton(
                  onPressed: () {
                    cartProvider.addItem(CartItem(
                      productId: product.id,
                      vendorId: product.vendorId,
                      name: product.name,
                      price: product.price,
                      imageUrl: product.imageUrl,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove,
                            color: Colors.white, size: 16),
                        onPressed: () =>
                            cartProvider.decreaseQuantity(product.id),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add,
                            color: Colors.white, size: 16),
                        onPressed: () =>
                            cartProvider.increaseQuantity(product.id),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
