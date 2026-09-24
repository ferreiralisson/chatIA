import 'package:flutter/cupertino.dart';

import '../models/conversation.dart';
import '../services/chat_service.dart';
import '../widgets/chat_widgets.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

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
          duration: Duration(milliseconds: 250), curve: Curves.easeOut);
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
        color: ChatPalette.of(context).sidebar,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 12, 20),
            child: Row(children: [
              Icon(CupertinoIcons.sparkles, size: 23),
              SizedBox(width: 10),
              Expanded(
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
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoButton(
              color: ChatPalette.of(context).selected,
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(14),
              onPressed: () {
                _newConversation();
                onSelected?.call();
              },
              child: Row(children: [
                Icon(CupertinoIcons.square_pencil,
                    size: 19, color: ChatPalette.of(context).text),
                SizedBox(width: 10),
                Text('Nova conversa',
                    style: TextStyle(
                        fontSize: 14, color: ChatPalette.of(context).text)),
              ]),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: Text('Suas conversas',
                style: TextStyle(
                    fontSize: 12,
                    color: ChatPalette.of(context).secondaryText,
                    fontWeight: FontWeight.w600)),
          ),
          Expanded(
              child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 12),
            children: _conversations
                .where((c) => c.messages.isNotEmpty)
                .map((c) => Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: CupertinoButton(
                        color: identical(c, _active)
                            ? ChatPalette.of(context).selected
                            : null,
                        borderRadius: BorderRadius.circular(10),
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        onPressed: () {
                          _select(c);
                          onSelected?.call();
                        },
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(c.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: ChatPalette.of(context).text))),
                      ),
                    ))
                .toList(),
          )),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(color: ChatPalette.of(context).line))),
            child: Row(children: [
              Icon(CupertinoIcons.chat_bubble_2,
                  size: 21, color: ChatPalette.of(context).secondaryText),
              SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Seu espaço de ideias',
                        style: TextStyle(fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Conversas nesta sessão',
                        style: TextStyle(
                            fontSize: 11,
                            color: ChatPalette.of(context).secondaryText)),
                  ])),
            ]),
          ),
        ]),
      );

  Widget _composer() => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 10, 10),
            decoration: BoxDecoration(
              color: ChatPalette.of(context).surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: ChatPalette.of(context).line),
            ),
            child: Column(children: [
              CupertinoTextField(
                key: Key('message-input'),
                controller: _input,
                focusNode: _focus,
                placeholder: 'Pergunte alguma coisa',
                placeholderStyle: TextStyle(
                    color: ChatPalette.of(context).secondaryText, fontSize: 16),
                decoration: null,
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                onChanged: (_) => setState(() {}),
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
              Row(children: [
                Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(CupertinoIcons.sparkles,
                        size: 16,
                        color: ChatPalette.of(context).secondaryText)),
                SizedBox(width: 6),
                Expanded(
                    child: Text('Vamos explorar uma ideia',
                        style: TextStyle(
                            fontSize: 12,
                            color: ChatPalette.of(context).secondaryText))),
                SizedBox(width: 8),
                Semantics(
                  label: 'Enviar mensagem',
                  button: true,
                  child: CupertinoButton(
                    key: Key('send-message'),
                    padding: EdgeInsets.all(12),
                    color: ChatPalette.of(context).text,
                    disabledColor: ChatPalette.of(context).disabled,
                    borderRadius: BorderRadius.circular(24),
                    onPressed: _active.isLoading || _input.text.trim().isEmpty
                        ? null
                        : () => _send(),
                    child: Icon(CupertinoIcons.arrow_up,
                        size: 20, color: ChatPalette.of(context).onAction),
                  ),
                ),
              ]),
            ]),
          ),
          SizedBox(height: 10),
          Text('A IA pode cometer erros. Confira informações importantes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: ChatPalette.of(context).secondaryText,
                  fontSize: 11,
                  height: 1.4)),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                    if (!wide)
                      ChatIconButton(
                          label: 'Abrir conversas',
                          icon: CupertinoIcons.sidebar_left,
                          onPressed: _showConversations),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('ChatIA',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                    ),
                    Spacer(),
                    ChatIconButton(
                      label: 'Configurações',
                      icon: CupertinoIcons.gear,
                      onPressed: () {
                        _focus.unfocus();
                        Navigator.of(context).push(CupertinoPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ));
                      },
                    ),
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
                              constraints: BoxConstraints(maxWidth: 800),
                              child: ListView(
                                controller: _scroll,
                                padding: EdgeInsets.fromLTRB(24, 28, 24, 12),
                                children: [
                                  ..._active.messages.map((m) => MessageView(
                                      key: ObjectKey(m), message: m)),
                                  if (_active.isLoading)
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 16),
                                      child: Row(children: [
                                        CupertinoActivityIndicator(radius: 8),
                                        SizedBox(width: 12),
                                        Text('Preparando uma resposta…',
                                            style: TextStyle(
                                                color: ChatPalette.of(context)
                                                    .secondaryText,
                                                fontSize: 14)),
                                      ]),
                                    ),
                                  if (_active.error != null)
                                    Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_active.error!,
                                              style: TextStyle(
                                                  color: CupertinoColors
                                                      .systemRed
                                                      .resolveFrom(context),
                                                  height: 1.5)),
                                          CupertinoButton(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12),
                                            onPressed: () => _send(retry: true),
                                            child: Text('Tentar novamente'),
                                          ),
                                        ]),
                                ],
                              ),
                            ),
                          )),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 800),
                        child: _composer())),
              ])),
            ]);
          }),
        ),
      );
}
