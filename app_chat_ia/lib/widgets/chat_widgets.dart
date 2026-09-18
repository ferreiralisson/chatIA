import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../models/conversation.dart';

const secondaryText = Color(0xFF737373);
const surface = Color(0xFFF4F4F4);
const line = Color(0xFFEAEAEA);

class ChatIconButton extends StatelessWidget {
  const ChatIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        button: true,
        child: CupertinoButton(
          padding: const EdgeInsets.all(12),
          onPressed: onPressed,
          child: Icon(icon, size: 21),
        ),
      );
}

class MessageView extends StatefulWidget {
  const MessageView({super.key, required this.message});
  final ChatMessage message;

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.message.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(children: [
                Icon(CupertinoIcons.sparkles, size: 19),
                SizedBox(width: 8),
                Text('ChatIA', style: TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: isUser ? 560 : double.infinity,
            ),
            margin: EdgeInsets.only(left: isUser ? 36 : 0),
            padding: isUser
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                : EdgeInsets.zero,
            decoration: isUser
                ? BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(24),
                  )
                : null,
            child: Text(widget.message.text,
                style: const TextStyle(fontSize: 16, height: 1.6)),
          ),
          if (!isUser)
            CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 8),
              onPressed: _copy,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  _copied
                      ? CupertinoIcons.check_mark
                      : CupertinoIcons.doc_on_doc,
                  size: 15,
                  color: secondaryText,
                ),
                const SizedBox(width: 6),
                Text(_copied ? 'Copiado' : 'Copiar',
                    style: const TextStyle(fontSize: 12, color: secondaryText)),
              ]),
            ),
        ],
      ),
    );
  }
}

class EmptyChat extends StatelessWidget {
  const EmptyChat({super.key, required this.onSuggestion});
  final ValueChanged<String> onSuggestion;

  static const suggestions = [
    (
      CupertinoIcons.lightbulb,
      'Entender um conceito',
      'Explique inteligência artificial com um exemplo do dia a dia.'
    ),
    (
      CupertinoIcons.pencil,
      'Criar um texto',
      'Ajude-me a escrever uma apresentação curta para um projeto da faculdade.'
    ),
    (
      CupertinoIcons.chevron_left_slash_chevron_right,
      'Explorar código',
      'Explique o que é uma API REST com um exemplo simples.'
    ),
    (
      CupertinoIcons.book,
      'Organizar meus estudos',
      'Monte um plano de estudos de programação para uma semana.'
    ),
  ];

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration:
                  const BoxDecoration(color: surface, shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.sparkles, size: 30),
            ),
            const SizedBox(height: 24),
            const Text('Como posso ajudar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -1)),
            const SizedBox(height: 10),
            const Text('Uma ideia, uma dúvida, um novo começo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryText, height: 1.5)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map((item) => CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => onSuggestion(item.$3),
                        child: Container(
                          width: 220,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: line),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(children: [
                            Icon(item.$1, size: 18, color: secondaryText),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(item.$2,
                                    style: const TextStyle(fontSize: 13))),
                          ]),
                        ),
                      ))
                  .toList(),
            ),
          ]),
        ),
      );
}
