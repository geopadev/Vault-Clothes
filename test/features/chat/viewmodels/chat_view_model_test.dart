import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_clothes/features/auth/services/user_account_manager.dart';
import 'package:vault_clothes/features/chat/models/message_model.dart';
import 'package:vault_clothes/features/chat/services/chat_service.dart';
import 'package:vault_clothes/features/chat/viewmodels/chat_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockChatService extends Mock implements ChatService {}
class MockUserAccountManager extends Mock implements UserAccountManager {}
class MockUser extends Mock implements User {}

void main() {
  late ChatViewModel viewModel;
  late MockChatService mockChatService;
  late MockUserAccountManager mockUserAccountManager;
  late MockUser mockUser;

  setUp(() {
    mockChatService = MockChatService();
    mockUserAccountManager = MockUserAccountManager();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('user123');
    when(() => mockUserAccountManager.currentUser).thenReturn(mockUser);
    
    // Mock getMessages stream
    when(() => mockChatService.getMessages('chat1'))
        .thenAnswer((_) => Stream.value([]));
  });

  void createViewModel() {
    viewModel = ChatViewModel(
      mockChatService,
      mockUserAccountManager,
      chatId: 'chat1',
      otherUserId: 'otherUser',
    );
  }

  test('init initializes stream', () {
    createViewModel();
    expect(viewModel.messagesStream, isNotNull);
  });

  test('sendMessage calls service with correct params', () async {
    createViewModel();
    
    when(() => mockChatService.sendMessage(
      chatId: 'chat1',
      senderId: 'user123',
      receiverId: 'otherUser',
      text: 'Hello',
    )).thenAnswer((_) async {});

    await viewModel.sendMessage('Hello');

    verify(() => mockChatService.sendMessage(
      chatId: 'chat1',
      senderId: 'user123',
      receiverId: 'otherUser',
      text: 'Hello',
    )).called(1);
  });

  test('sendMessage does nothing if text is empty', () async {
    createViewModel();
    await viewModel.sendMessage('   ');
    verifyNever(() => mockChatService.sendMessage(
      chatId: any(named: 'chatId'), 
      senderId: any(named: 'senderId'), 
      receiverId: any(named: 'receiverId'), 
      text: any(named: 'text')
    ));
  });
}
