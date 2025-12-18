import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug - Firestore Data'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vendors Collection:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('vendors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '⚠️ NO VENDORS FOUND IN FIRESTORE!\n\nThis means no vendor document was created when the shopkeeper signed up.\n\nCheck:\n1. Did signup complete successfully?\n2. Check Firebase Console -> Firestore -> vendors collection',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(data['name'] ?? 'No name'),
                        subtitle: Text('ID: ${doc.id}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildField('Category', data['category']),
                                _buildField('Description', data['description']),
                                _buildField('Owner ID', data['ownerId']),
                                _buildField('Phone', data['phone']),
                                _buildField('Address', data['address']),
                                _buildField('Rating', data['rating']),
                                _buildField('Delivery Time', data['deliveryTime']),
                                _buildField('Min Order', data['minimumOrder']),
                                _buildField('Is Open', data['isOpen']),
                                _buildField('Created At', data['createdAt']),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Products Collection:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '⚠️ NO PRODUCTS FOUND IN FIRESTORE!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(data['name'] ?? 'No name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${doc.id}'),
                            Text('Vendor ID: ${data['vendorId'] ?? 'MISSING!'}'),
                            Text('Price: Rs ${data['price']}'),
                            Text('Stock: ${data['stock']}'),
                            Text('Available: ${data['isAvailable']}'),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'null',
              style: TextStyle(
                color: value == null ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
