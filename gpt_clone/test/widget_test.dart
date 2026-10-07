import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:gpt_clone/main.dart';
import 'package:gpt_clone/services/chat_service.dart';

void main() {
  group('ChatService', () {
    test('retorna a resposta da API', () async {
      final service = ChatService(
        baseUrl: 'http://api.test/',
        client: MockClient((request) async {
          expect(request.url.toString(), 'http://api.test/ask');
          return http.Response(
            '{"response":"olá"}',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      expect(await service.ask('oi'), 'olá');
    });

    test('lança ChatException quando o status não é 200', () async {
      final service = ChatService(
        baseUrl: 'http://api.test',
        client: MockClient((_) async => http.Response('', 500)),
      );
      expect(service.ask('oi'), throwsA(isA<ChatException>()));
    });
  });

  testWidgets('envia pergunta e exibe a resposta', (tester) async {
    final service = ChatService(
      baseUrl: 'http://api.test',
      client: MockClient(
        (_) async => http.Response('{"response":"resposta teste"}', 200),
      ),
    );

    await tester.pumpWidget(ChatApp(service: service));
    await tester.enterText(find.byType(CupertinoTextField), 'pergunta teste');
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-message')));
    await tester.pumpAndSettle();

    expect(find.text('pergunta teste'), findsWidgets);
    expect(find.textContaining('resposta teste'), findsWidgets);
  });
}
