import 'package:app_chat_ia/services/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('Uses the configured API URL and decodes UTF-8', () async {
    final service = ChatService(
        baseUrl: 'http://example.test:8080/',
        client: MockClient((request) async {
          expect(request.url.toString(), 'http://example.test:8080/ask');
          return http.Response('{"response":"Olá, você!"}', 200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }));
    addTearDown(service.close);
    expect(await service.ask('Oi'), 'Olá, você!');
  });
  for (final body in [
    'invalid',
    '{}',
    '{"response":null}',
    '{"response":" "}'
  ]) {
    test('Rejects invalid response: $body', () async {
      final service = ChatService(
          client: MockClient((_) async => http.Response(body, 200)));
      addTearDown(service.close);
      await expectLater(service.ask('Oi'), throwsA(isA<ChatException>()));
    });
  }
}
