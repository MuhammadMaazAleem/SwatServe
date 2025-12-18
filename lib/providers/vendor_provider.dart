import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vendor_model.dart';
import '../models/product_model.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VendorModel> _vendors = [];
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<VendorModel> get vendors => _filteredVendors;
  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<VendorModel> get _filteredVendors {
    List<VendorModel> filtered = _vendors;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((vendor) => vendor.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (vendor) =>
                vendor.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                vendor.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadVendors() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('vendors')
          .get();

      _vendors = snapshot.docs
          .map((doc) => VendorModel.fromFirestore(doc))
          .toList();
      
      // Sort in memory instead of using Firestore orderBy
      _vendors.sort((a, b) => b.rating.compareTo(a.rating));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error loading vendors: $e');
    }
  }

  Future<void> loadProductsByVendor(String vendorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .where('isAvailable', isEqualTo: true)
          .get();

      _products = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ProductModel>> getFeaturedProducts(
    String vendorId, {
    int limit = 3,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('vendorId', isEqualTo: vendorId)
          .where('isAvailable', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  VendorModel? getVendorById(String id) {
    try {
      return _vendors.firstWhere((vendor) => vendor.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addVendor(VendorModel vendor) async {
    try {
      await _firestore.collection('vendors').doc(vendor.id).set(vendor.toMap());
      await loadVendors();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateVendor(VendorModel vendor) async {
    try {
      await _firestore
          .collection('vendors')
          .doc(vendor.id)
          .update(vendor.toMap());
      await loadVendors();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteVendor(String vendorId) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).delete();
      await loadVendors();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
