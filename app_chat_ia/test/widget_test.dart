import 'dart:async';
import 'dart:convert';
import 'package:app_chat_ia/main.dart';
import 'package:app_chat_ia/services/chat_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('Cupertino layout fits mobile and desktop', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    for (final size in [const Size(390, 844), const Size(1280, 800)]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const ChatApp());
      expect(find.byType(CupertinoApp), findsOneWidget);
      expect(find.text('Como posso ajudar?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Sends a question, prevents duplicate sends and shows the answer',
      (tester) async {
    final completer = Completer<http.Response>();
    var calls = 0;
    final service = ChatService(client: MockClient((request) {
      calls++;
      expect(jsonDecode(request.body), {'question': 'Olá!'});
      return completer.future;
    }));
    addTearDown(service.close);
    await tester.pumpWidget(ChatApp(service: service));
    await tester.enterText(find.byKey(const Key('message-input')), 'Olá!');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pump();
    expect(find.text('Preparando uma resposta…'), findsOneWidget);
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    expect(calls, 1);
    completer.complete(http.Response(
        jsonEncode({'response': 'Olá, turma!'}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'}));
    await tester.pumpAndSettle();
    expect(find.text('Olá, turma!'), findsOneWidget);
    expect(find.text('Preparando uma resposta…'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Can retry an error without duplicating the question',
      (tester) async {
    var calls = 0;
    final service = ChatService(client: MockClient((_) async {
      calls++;
      return calls == 1
          ? http.Response('unavailable', 503)
          : http.Response('{"response":"Resposta recuperada"}', 200);
    }));
    addTearDown(service.close);
    await tester.pumpWidget(ChatApp(service: service));
    await tester.enterText(find.byKey(const Key('message-input')), 'Teste');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Resposta recuperada'), findsOneWidget);
    expect(find.text('Teste'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('Mobile menu restores conversations after starting a new one',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final service = ChatService(
        client: MockClient((_) async => http.Response(
            '{"response":"Resposta da primeira conversa"}', 200)));
    addTearDown(service.close);
    await tester.pumpWidget(ChatApp(service: service));
    await tester.enterText(
        find.byKey(const Key('message-input')), 'Primeira pergunta');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(CupertinoIcons.square_pencil));
    await tester.pumpAndSettle();
    expect(find.text('Como posso ajudar?'), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.sidebar_left));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Primeira pergunta'));
    await tester.pumpAndSettle();
    expect(find.text('Resposta da primeira conversa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Late response after leaving the screen is safe', (tester) async {
    final completer = Completer<http.Response>();
    final service = ChatService(client: MockClient((_) => completer.future));
    addTearDown(service.close);
    await tester.pumpWidget(ChatApp(service: service));
    await tester.enterText(find.byKey(const Key('message-input')), 'Teste');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    completer.complete(http.Response('{"response":"Resposta"}', 200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
