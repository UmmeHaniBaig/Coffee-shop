import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/models/loyalty_model.dart';

class LoyaltyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get loyalty info for a user
  Future<LoyaltyModel> getLoyalty(String userPhone) async {
    try {
      final doc = await _firestore.collection('loyalty').doc(userPhone).get();
      if (doc.exists) {
        return LoyaltyModel.fromFirestore(doc.data()!);
      } else {
        return LoyaltyModel(userPhone: userPhone, stars: 0, tier: 'Bronze');
      }
    } catch (e) {
      print('Error fetching loyalty: $e');
      return LoyaltyModel(userPhone: userPhone, stars: 0, tier: 'Bronze');
    }
  }

  // Add stars after an order (1 star per $1 spent, rounded down)
  Future<void> addStars(String userPhone, double orderTotal) async {
    try {
      final docRef = _firestore.collection('loyalty').doc(userPhone);
      final doc = await docRef.get();

      int currentStars = 0;
      if (doc.exists) {
        currentStars = doc.data()?['stars'] ?? 0;
      }

      int starsEarned = orderTotal.floor();
      int newStars = currentStars + starsEarned;
      String newTier = LoyaltyModel.getTierForStars(newStars);

      await docRef.set({
        'userPhone': userPhone,
        'stars': newStars,
        'tier': newTier,
      });
    } catch (e) {
      print('Error adding stars: $e');
    }
  }
}