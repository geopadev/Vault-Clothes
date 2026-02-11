import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vault_clothes/core/services/service_locator.dart';
import 'package:vault_clothes/features/chat/models/chat_model.dart';
import 'package:vault_clothes/features/chat/viewmodels/inbox_view_model.dart';
import 'package:vault_clothes/features/chat/views/chat_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InboxViewModel>(
      create: (_) => getIt<InboxViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inbox', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: false,
          elevation: 0,
        ),
        body: Consumer<InboxViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<List<ChatModel>>(
              stream: viewModel.chatsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final chats = snapshot.data ?? [];

                if (chats.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No conversations yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final isBuyer = chat.buyerId == viewModel.currentUserId;
                    // Provide the ID of the OTHER user for the chat screen
                    final otherUserId = isBuyer ? chat.sellerId : chat.buyerId;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              otherUserId: otherUserId,
                              listingId: chat.listingId,
                              listingTitle: chat.listingTitle,
                              listingImage: chat.listingImage,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey[200],
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                      title: Text(
                        chat.listingTitle, // Vinted style: Listing Title prominent
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Item inquiry',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: chat.lastMessage.isNotEmpty ? Colors.black87 : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(chat.lastMessageTime),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ]),
                      trailing: chat.listingImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                chat.listingImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    width: 50, height: 50, color: Colors.grey[200]),
                              ),
                            )
                          : Container(width: 50, height: 50, color: Colors.grey[200]),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Vinted-like sparse timestamp
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays < 1) {
      return DateFormat.Hm().format(date);
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(date);
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
