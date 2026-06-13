import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts() async {
    try {
      final snapshot = await _firestore.collection('coffee_products').get();
      print('Documents found: ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('coffee_products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}