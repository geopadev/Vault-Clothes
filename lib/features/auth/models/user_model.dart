class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final int trustRating;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.trustRating = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      trustRating: (json['trustRating'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
      'trustRating': trustRating,
    };
  }
}
