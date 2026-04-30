import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rick_morty/models/api_response.dart';
import 'package:rick_morty/models/character.dart';
import 'package:rick_morty/models/episode.dart';
import 'package:rick_morty/models/location.dart';

class ApiService {
  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  static Future<ApiResponse<Character>> getCharacters({
    int page = 1,
    String? name,
    String? status,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (name != null && name.isNotEmpty) params['name'] = name;
    if (status != null && status.isNotEmpty) params['status'] = status;

    final uri =
        Uri.parse('$_baseUrl/character').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse<Character>(
        info: ApiInfo.fromJson(json['info'] as Map<String, dynamic>),
        results: (json['results'] as List<dynamic>)
            .map((e) => Character.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (response.statusCode == 404) {
      return ApiResponse<Character>(
          info: ApiInfo(count: 0, pages: 0), results: []);
    }
    throw Exception('Failed to load characters: ${response.statusCode}');
  }

  static Future<Character> getCharacter(int id) async {
    final uri = Uri.parse('$_baseUrl/character/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return Character.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load character: ${response.statusCode}');
  }

  static Future<List<Character>> getCharactersByUrls(
      List<String> urls) async {
    if (urls.isEmpty) return [];
    final ids = urls.map((url) => url.split('/').last).join(',');
    final uri = Uri.parse('$_baseUrl/character/$ids');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is List) {
        return body
            .map((e) => Character.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [Character.fromJson(body as Map<String, dynamic>)];
      }
    }
    throw Exception('Failed to load characters: ${response.statusCode}');
  }

  static Future<ApiResponse<Episode>> getEpisodes({
    int page = 1,
    String? name,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (name != null && name.isNotEmpty) params['name'] = name;

    final uri =
        Uri.parse('$_baseUrl/episode').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse<Episode>(
        info: ApiInfo.fromJson(json['info'] as Map<String, dynamic>),
        results: (json['results'] as List<dynamic>)
            .map((e) => Episode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (response.statusCode == 404) {
      return ApiResponse<Episode>(
          info: ApiInfo(count: 0, pages: 0), results: []);
    }
    throw Exception('Failed to load episodes: ${response.statusCode}');
  }

  static Future<ApiResponse<Location>> getLocations({
    int page = 1,
    String? name,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (name != null && name.isNotEmpty) params['name'] = name;

    final uri =
        Uri.parse('$_baseUrl/location').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse<Location>(
        info: ApiInfo.fromJson(json['info'] as Map<String, dynamic>),
        results: (json['results'] as List<dynamic>)
            .map((e) => Location.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else if (response.statusCode == 404) {
      return ApiResponse<Location>(
          info: ApiInfo(count: 0, pages: 0), results: []);
    }
    throw Exception('Failed to load locations: ${response.statusCode}');
  }

  static Future<Location> getLocation(int id) async {
    final uri = Uri.parse('$_baseUrl/location/$id');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return Location.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load location: ${response.statusCode}');
  }
}
