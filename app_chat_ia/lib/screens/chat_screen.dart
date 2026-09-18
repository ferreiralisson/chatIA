import 'package:flutter/cupertino.dart';

import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.service});
  final ChatService? service;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  final _conversations = <Conversation>[Conversation()];
  late final ChatService _service = widget.service ?? ChatService();
  late Conversation _active = _conversations.first;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _focus.dispose();
    if (widget.service == null) _service.close();
    super.dispose();
  }

  void _select(Conversation conversation) {
    _active.draft = _input.text;
    setState(() {
      _active = conversation;
      _input.text = conversation.draft;
    });
    _scrollToBottom();
  }

  void _newConversation() {
    final empty = _conversations.where((c) => c.messages.isEmpty);
    if (empty.isNotEmpty) {
      _select(empty.first);
    } else {
      final conversation = Conversation();
      setState(() => _conversations.insert(0, conversation));
      _select(conversation);
    }
    _focus.requestFocus();
  }

  Future<void> _send({bool retry = false}) async {
    final conversation = _active;
    final question =
        retry ? conversation.messages.last.text : _input.text.trim();
    if (question.isEmpty || conversation.isLoading) return;
    setState(() {
      conversation.error = null;
      conversation.isLoading = true;
      if (!retry) {
        conversation.messages.add(ChatMessage(MessageRole.user, question));
        conversation.draft = '';
        _input.clear();
      }
    });
    _scrollToBottom();
    try {
      final answer = await _service.ask(question);
      if (!mounted) return;
      setState(() => conversation.messages
          .add(ChatMessage(MessageRole.assistant, answer)));
    } on ChatException catch (error) {
      if (!mounted) return;
      setState(() => conversation.error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() =>
          conversation.error = 'Não foi possível enviar. Tente novamente.');
    } finally {
      if (mounted) {
        setState(() => conversation.isLoading = false);
        if (identical(conversation, _active)) _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  void _showConversations() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (sheetContext) => CupertinoPopupSurface(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .75,
          child: SafeArea(
            top: false,
            child: _sidebar(onSelected: () => Navigator.pop(sheetContext)),
          ),
        ),
      ),
    );
  }

  Widget _sidebar({VoidCallback? onSelected}) => Container(
        color: const Color(0xFFF9F9F9),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
            child: Row(children: [
              const Icon(CupertinoIcons.sparkles, size: 23),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('ChatIA',
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w600))),
              if (onSelected != null)
                ChatIconButton(
                    label: 'Fechar conversas',
                    icon: CupertinoIcons.xmark,
                    onPressed: onSelected),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoButton(
              color: const Color(0xFFECECEC),
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.all(14),
              onPressed: () {
                _newConversation();
                onSelected?.call();
              },
              child: const Row(children: [
                Icon(CupertinoIcons.square_pencil,
                    size: 19, color: Color(0xFF202123)),
                SizedBox(width: 10),
                Text('Nova conversa',
                    style: TextStyle(fontSize: 14, color: Color(0xFF202123))),
              ]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: Text('Suas conversas',
                style: TextStyle(
                    fontSize: 12,
                    color: secondaryText,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _conversations
                .where((c) => c.messages.isNotEmpty)
                .map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: CupertinoButton(
                        color: identical(c, _active)
                            ? const Color(0xFFECECEC)
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        onPressed: () {
                          _select(c);
                          onSelected?.call();
                        },
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF202123)))),
                      ),
                    ))
                .toList(),
          )),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: line))),
            child: const Row(children: [
              Icon(CupertinoIcons.chat_bubble_2,
                  size: 21, color: secondaryText),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Seu espaço de ideias',
                        style: TextStyle(fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Conversas nesta sessão',
                        style: TextStyle(fontSize: 11, color: secondaryText)),
                  ])),
            ]),
          ),
        ]),
      );

  Widget _composer() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 10, 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Column(children: [
              CupertinoTextField(
                key: const Key('message-input'),
                controller: _input,
                focusNode: _focus,
                placeholder: 'Pergunte alguma coisa',
                placeholderStyle:
                    const TextStyle(color: secondaryText, fontSize: 16),
                decoration: null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              Row(children: [
                const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(CupertinoIcons.sparkles,
                        size: 16, color: secondaryText)),
                const SizedBox(width: 6),
                const Expanded(
                    child: Text('Vamos explorar uma ideia',
                        style: TextStyle(fontSize: 12, color: secondaryText))),
                const SizedBox(width: 8),
                Semantics(
                  label: 'Enviar mensagem',
                  button: true,
                  child: CupertinoButton(
                    key: const Key('send-message'),
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF202123),
                    disabledColor: const Color(0xFFD6D6D6),
                    borderRadius: BorderRadius.circular(24),
                    onPressed: _active.isLoading || _input.text.trim().isEmpty
                        ? null
                        : () => _send(),
                    child: const Icon(CupertinoIcons.arrow_up,
                        size: 20, color: CupertinoColors.white),
                  ),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 10),
          const Text(
              'A IA pode cometer erros. Confira informações importantes.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: secondaryText, fontSize: 11, height: 1.4)),
        ]),
      );

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Row(children: [
              if (wide) SizedBox(width: 260, child: _sidebar()),
              Expanded(
                  child: Column(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    if (!wide)
                      ChatIconButton(
                          label: 'Abrir conversas',
                          icon: CupertinoIcons.sidebar_left,
                          onPressed: _showConversations),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ChatIA',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    ChatIconButton(
                        label: 'Nova conversa',
                        icon: CupertinoIcons.square_pencil,
                        onPressed: _newConversation),
                  ]),
                ),
                Expanded(
                    child: _active.messages.isEmpty
                        ? EmptyChat(onSuggestion: (text) {
                            setState(() => _input.text = text);
                            _focus.requestFocus();
                          })
                        : Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: ListView(
                                controller: _scroll,
                                padding:
                                    const EdgeInsets.fromLTRB(24, 28, 24, 12),
                                children: [
                                  ..._active.messages.map((m) => MessageView(
                                      key: ObjectKey(m), message: m)),
                                  if (_active.isLoading)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Row(children: [
                                        CupertinoActivityIndicator(radius: 8),
                                        SizedBox(width: 12),
                                        Text('Preparando uma resposta…',
                                            style: TextStyle(
                                                color: secondaryText,
                                                fontSize: 14)),
                                      ]),
                                    ),
                                  if (_active.error != null)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_active.error!,
                                              style: const TextStyle(
                                                  color:
                                                      CupertinoColors.systemRed,
                                                  height: 1.5)),
                                          CupertinoButton(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                            onPressed: () => _send(retry: true),
                                            child:
                                                const Text('Tentar novamente'),
                                          ),
                                        ]),
                                ],
                              ),
                            ),
                          )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: _composer())),
              ])),
            ]);
          }),
        ),
      );
}
