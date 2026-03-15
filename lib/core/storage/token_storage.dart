import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _key = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  /// Returns valid token or null (already expired or invalid)
  Future<String?> getValidToken() async {
    final token = await _storage.read(key: _key);
    if (token == null || token.isEmpty) return null;

    // Quick client-side check → optimization
    if (JwtDecoder.isExpired(token)) {
      await clearToken();
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    if (decoded['id'] == null) {
      await clearToken();
      return null;
    }

    return token;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _key);
  }
}
