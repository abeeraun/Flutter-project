import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/api_exception.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String path) {
    final base = ApiConstants.baseUrl.endsWith('/')
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
        : ApiConstants.baseUrl;
    return Uri.parse('$base$path');
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await _client
          .get(_buildUri(path), headers: {'Accept': 'application/json'})
          .timeout(ApiConstants.timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppStrings.noInternet);
    } on TimeoutException {
      throw ApiException('The API request timed out. Verify Apache and MySQL are running.');
    } on http.ClientException catch (e) {
      throw ApiException('API connection failed: ${e.message}');
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    return _send('POST', path, body);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    return _send('PUT', path, body);
  }

  Future<dynamic> _send(String method, String path, Map<String, dynamic> body) async {
    try {
      final request = http.Request(method, _buildUri(path));
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'application/json';
      request.body = jsonEncode(body);
      final response = await _client.send(request).timeout(ApiConstants.timeoutDuration);
      return _handleResponse(await http.Response.fromStream(response));
    } on SocketException {
      throw ApiException(AppStrings.noInternet);
    } on TimeoutException {
      throw ApiException('The API request timed out. Verify Apache and MySQL are running.');
    } on http.ClientException catch (e) {
      throw ApiException('API connection failed: ${e.message}');
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _client
          .delete(_buildUri(path), headers: {'Accept': 'application/json'})
          .timeout(ApiConstants.timeoutDuration);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException(AppStrings.noInternet);
    } on TimeoutException {
      throw ApiException('The API request timed out. Verify Apache and MySQL are running.');
    } on http.ClientException catch (e) {
      throw ApiException('API connection failed: ${e.message}');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final status = response.statusCode;
    dynamic decoded;
    try {
      decoded = response.body.trim().isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      throw ApiException('API returned invalid JSON (HTTP $status). Check the API URL and Apache rewrite rules.');
    }
    if (status >= 200 && status < 300) return decoded;
    final message = decoded is Map && decoded['message'] != null
        ? decoded['message'].toString()
        : 'API request failed with HTTP $status.';
    throw ApiException(message);
  }
}
