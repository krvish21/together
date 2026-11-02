import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String _customBaseUrl = '';

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  static String get defaultHost {
    // Allows embedding production URL during build: flutter build apk --dart-define=BACKEND_URL=https://your-api.koyeb.app
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    if (kIsWeb) return 'http://localhost:4000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:4000';
      }
    } catch (_) {}
    return 'http://localhost:4000';
  }

  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) {
      return _customBaseUrl;
    }
    return defaultHost;
  }

  static String get wsUrl {
    final uri = Uri.parse(baseUrl);
    final scheme = (uri.scheme == 'https' || uri.scheme == 'wss') ? 'wss' : 'ws';
    final portSegment = (uri.hasPort && uri.port != 80 && uri.port != 443) ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$portSegment/ws';
  }
}
