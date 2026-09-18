enum MessageRole { user, assistant }

class ChatMessage {
  const ChatMessage(this.role, this.text);

  final MessageRole role;
  final String text;
}

class Conversation {
  final List<ChatMessage> messages = [];
  bool isLoading = false;
  String? error;
  String draft = '';

  String get title => messages.isEmpty ? 'Nova conversa' : messages.first.text;
}
