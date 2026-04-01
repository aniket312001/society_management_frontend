import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class MediaUploadService {
  static final _storage = Supabase.instance.client.storage;
  static const _bucket = 'uploads';

  /// Uploads [file] and returns its public URL.
  /// [fileType] must be 'image' or 'video'.
  static Future<String> upload(File file, String fileType) async {
    final ext = file.path.split('.').last;
    final folder = fileType == 'image' ? 'images' : 'videos';
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _storage.from(_bucket).upload(path, file);

    return _storage.from(_bucket).getPublicUrl(path);
  }
}
