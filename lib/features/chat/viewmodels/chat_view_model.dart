import 'dart:async';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/chat/models/message_model.dart';
import 'package:vault_clothes/features/chat/services/chat_service.dart';

class ChatViewModel extends BaseViewModel {
  final ChatService _chatService;
  final UserAccountManager _userAccountManager;
  final String chatId;
  final String otherUserId;

  Stream<List<MessageModel>>? _messagesStream;
  Stream<List<MessageModel>>? get messagesStream => _messagesStream;

  String get currentUserId => _userAccountManager.currentUser?.uid ?? '';

  ChatViewModel(
    this._chatService,
    this._userAccountManager, {
    required this.chatId,
    required this.otherUserId,
  }) {
    _init();
  }

  void _init() {
    setLoading(true);
    _messagesStream = _chatService.getMessages(chatId);
    setLoading(false);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    await runSafe(() async {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: currentUserId,
        receiverId: otherUserId,
        text: text.trim(),
      );
    });
  }
}
