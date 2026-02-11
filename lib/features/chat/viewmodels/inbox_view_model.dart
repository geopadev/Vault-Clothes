import 'dart:async';
import 'package:vault_clothes/core/viewmodels/base_view_model.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/chat/models/chat_model.dart';
import 'package:vault_clothes/features/chat/services/chat_service.dart';

class InboxViewModel extends BaseViewModel {
  final ChatService _chatService;
  final UserAccountManager _userAccountManager;

  Stream<List<ChatModel>>? _chatsStream;
  Stream<List<ChatModel>>? get chatsStream => _chatsStream;

  String get currentUserId => _userAccountManager.currentUser?.uid ?? '';

  InboxViewModel(this._chatService, this._userAccountManager) {
    _init();
  }

  void _init() {
    setLoading(true);
    final uid = currentUserId;
    if (uid.isNotEmpty) {
      _chatsStream = _chatService.getUserChats(uid);
    }
    setLoading(false);
  }
}
