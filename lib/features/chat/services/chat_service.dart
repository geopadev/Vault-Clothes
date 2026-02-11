import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vault_clothes/core/services/database_connector.dart';
import 'package:vault_clothes/features/chat/models/chat_model.dart';
import 'package:vault_clothes/features/chat/models/message_model.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final DatabaseConnector _db;
  final _uuid = const Uuid();

  ChatService(this._db);

  /// Creates or retrieves an existing chat for a specific listing and buyer-seller pair.
  Future<String> startChat({
    required String buyerId,
    required String sellerId,
    required String listingId,
    required String listingTitle,
    required String listingImage,
  }) async {
    // Check if chat exists uniquely by listingId + participants?
    // Firestore queries can be complex. 
    // To simplify: we can check if a chat document exists where `listingId` == listingId AND `participants` contains both.
    // Or we can construct a deterministic ID if we want 1 chat per listing per pair: listingId_buyerId_sellerId.
    
    final chatId = '${listingId}_${buyerId}_$sellerId';
    
    final existing = await _db.getDocument('chats', chatId);
    
    if (existing != null) {
      return chatId;
    }

    // Create new chat
    final chat = ChatModel(
      id: chatId,
      participants: [buyerId, sellerId],
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      listingId: listingId,
      listingTitle: listingTitle,
      listingImage: listingImage,
      buyerId: buyerId,
      sellerId: sellerId,
    );

    await _db.saveDocument('chats', chatId, chat.toJson());
    return chatId;
  }

  Stream<List<ChatModel>> getUserChats(String userId) {
    return _db.collectionStream(
      'chats',
      // We need to filter where participants array-contains userId.
      // FirestoreDatabaseConnector needs to support `where` clauses generic or specifically designed.
      // Assuming our connector supports query builder or we implement specific query method in connector.
      // If connector is limited, we might need to update it.
      // Checking `FirestoreDatabaseConnector` implementation (from memory/context):
      // It has `collectionStream` with `orderBy`, `descending`.
      // It might NOT have `where`.
      // I'll need to check DatabaseConnector.
      orderBy: 'lastMessageTime',
      descending: true,
    ).map((list) {
      // Client-side filtering if DB connector doesn't support 'where'.
      // inefficient for production but ok for MVP if dataset small.
      // Ideally, update DatabaseConnector to support `where` clauses.
      return list
          .map((data) => ChatModel.fromJson(data))
          .where((chat) => chat.participants.contains(userId))
          .toList();
    });
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return _db.collectionStream(
      'chats/$chatId/messages',
      orderBy: 'timestamp',
      descending: true, // Listview usually reversed
    ).map((list) => list.map((data) => MessageModel.fromJson(data)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required String receiverId, // Useful for notifications later
  }) async {
    final messageId = _uuid.v4();
    final message = MessageModel(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: DateTime.now(),
    );

    // Save message to subcollection
    await _db.saveDocument('chats/$chatId/messages', messageId, message.toJson());

    // Update Chat metadata (last message)
    await _db.updateDocument('chats', chatId, {
      'lastMessage': text,
      'lastMessageTime': Timestamp.fromDate(message.timestamp),
    });
  }
}
