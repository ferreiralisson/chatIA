import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatException implements Exception {
  const ChatException(this.message);
  final String message;
}

class ChatService {
  ChatService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:8080',
            );

  final http.Client _client;
  final String _baseUrl;

  Future<String> ask(String question) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${_baseUrl.replaceFirst(RegExp(r'/+$'), '')}/ask'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'question': question}),
          )
          .timeout(const Duration(minutes: 2));
      if (response.statusCode != 200) {
        throw const ChatException(
          'Não foi possível gerar a resposta. Tente novamente.',
        );
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map<String, dynamic> ||
          data['response'] is! String ||
          (data['response'] as String).trim().isEmpty) {
        throw const ChatException('O assistente retornou uma resposta vazia.');
      }
      return data['response'] as String;
    } on TimeoutException {
      throw const ChatException(
        'A resposta demorou mais que o esperado. Tente novamente.',
      );
    } on http.ClientException {
      throw const ChatException(
        'Não foi possível conectar. Verifique se a API está em execução.',
      );
    } on FormatException {
      throw const ChatException('A API retornou uma resposta inválida.');
    }
  }

  void close() => _client.close();
}
