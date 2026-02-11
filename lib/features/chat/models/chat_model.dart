import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String listingId;
  final String listingTitle;
  final String listingImage;
  final String buyerId;
  final String sellerId;

  ChatModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.listingId,
    required this.listingTitle,
    required this.listingImage,
    required this.buyerId,
    required this.sellerId,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTime: (json['lastMessageTime'] as Timestamp).toDate(),
      listingId: json['listingId'] ?? '',
      listingTitle: json['listingTitle'] ?? '',
      listingImage: json['listingImage'] ?? '',
      buyerId: json['buyerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingImage': listingImage,
      'buyerId': buyerId,
      'sellerId': sellerId,
    };
  }
}
