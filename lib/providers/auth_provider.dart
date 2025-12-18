import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  String get userRole => _currentUser?.role ?? '';
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isShopkeeper => _currentUser?.role == 'shopkeeper';
  bool get isCustomer => _currentUser?.role == 'customer';

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Public method to reload user data
  Future<void> loadUserData() async {
    if (_currentUser != null) {
      await _loadUserData(_currentUser!.id);
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData(credential.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    String? licenseNumber,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // For shopkeepers, check if limit is reached
      if (role == 'shopkeeper') {
        QuerySnapshot shopkeepers = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'shopkeeper')
            .get();

        if (shopkeepers.docs.length >= 40) {
          _error = 'Maximum shopkeeper limit (40) reached';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? shopId;

      // If shopkeeper, create a vendor/shop for them
      if (role == 'shopkeeper') {
        final vendorDoc = await _firestore.collection('vendors').add({
          'name': '$name\'s Shop',
          'description': 'Welcome to my shop! Browse our products and enjoy quality service.',
          'category': 'General',
          'ownerId': credential.user!.uid,
          'ownerName': name,
          'ownerEmail': email,
          'ownerPhone': phone,
          'phone': phone,
          'address': 'Shamozai, Swat Valley, Pakistan',
          'imageUrl': '',
          'rating': 4.5,
          'totalReviews': 0,
          'deliveryTime': '30-45 min',
          'minimumOrder': 100.0,
          'isOpen': true,
          'isFeatured': false,
          'offers': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
        shopId = vendorDoc.id;
      }

      UserModel newUser = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        shopId: shopId,
        isVerified: role != 'shopkeeper', // Shopkeepers need admin verification
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      // If shopkeeper, create pending verification document
      if (role == 'shopkeeper' && licenseNumber != null) {
        await _firestore
            .collection('pending_verifications')
            .doc(credential.user!.uid)
            .set({
          'userId': credential.user!.uid,
          'licenseNumber': licenseNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    if (_currentUser == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updates);

      _currentUser = _currentUser!.copyWith(
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAddress(String address) async {
    if (_currentUser == null) return false;

    try {
      List<String> addresses = List.from(_currentUser!.addresses);
      addresses.add(address);

      await _firestore.collection('users').doc(_currentUser!.id).update({
        'addresses': addresses,
      });

      _currentUser = _currentUser!.copyWith(addresses: addresses);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
