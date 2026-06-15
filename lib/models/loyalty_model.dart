class LoyaltyModel {
  final String userPhone;
  final int stars;
  final String tier;

  LoyaltyModel({
    required this.userPhone,
    required this.stars,
    required this.tier,
  });

  factory LoyaltyModel.fromFirestore(Map<String, dynamic> data) {
    return LoyaltyModel(
      userPhone: data['userPhone'] ?? '',
      stars: data['stars'] ?? 0,
      tier: data['tier'] ?? 'Bronze',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userPhone': userPhone,
      'stars': stars,
      'tier': tier,
    };
  }

  static String getTierForStars(int stars) {
    if (stars >= 200) return 'Gold';
    if (stars >= 100) return 'Silver';
    return 'Bronze';
  }
}