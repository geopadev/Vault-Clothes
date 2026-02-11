import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/chat/models/message_model.dart';
import 'package:vault_clothes/features/chat/services/chat_service.dart';
import 'package:vault_clothes/features/chat/viewmodels/chat_view_model.dart';
import 'package:vault_clothes/features/chat/views/widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String listingId;
  final String listingTitle;
  final String listingImage;
  final String? listingPrice; // Optional if available (String for simplicity in passing)

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.listingId,
    required this.listingTitle,
    required this.listingImage,
    this.listingPrice,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatViewModel>(
      create: (_) => ChatViewModel(
        getIt<ChatService>(),
        getIt<UserAccountManager>(),
        chatId: widget.chatId,
        otherUserId: widget.otherUserId,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 1,
        ),
        body: Column(
          children: [
            // Item Context Header (Vinted Style)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: widget.listingImage.isNotEmpty
                        ? Image.network(widget.listingImage,
                            width: 48, height: 48, fit: BoxFit.cover)
                        : Container(width: 48, height: 48, color: Colors.grey[200]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.listingTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (widget.listingPrice != null)
                          Text(widget.listingPrice!,
                              style: const TextStyle(color: Colors.teal)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      // Navigate to listing? Or "Buy"?
                      // For MVP just a button
                    },
                    child: const Text('View Item'),
                  ),
                ],
              ),
            ),
            
            // Messages List
            Expanded(
              child: Consumer<ChatViewModel>(
                builder: (context, viewModel, child) {
                  return StreamBuilder<List<MessageModel>>(
                    stream: viewModel.messagesStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final messages = snapshot.data ?? [];
                      
                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true, // Messages load bottom up
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return ChatBubble(
                            message: msg.text,
                            isMe: msg.senderId == viewModel.currentUserId,
                            time: msg.timestamp,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            
            // Input Area
            Consumer<ChatViewModel>(
              builder: (context, viewModel, _) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.grey),
                        onPressed: () {}, // Attachment (future)
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Write a message...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.teal),
                        onPressed: () {
                          final text = _controller.text;
                          _controller.clear();
                          viewModel.sendMessage(text);
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}
