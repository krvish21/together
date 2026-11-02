class ApiConfig {
  // Live deployed Render production backend
  static const String productionUrl = 'https://together-z41x.onrender.com';
  static String _customBaseUrl = '';

  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url.trim();
  }

  static String get defaultHost {
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return productionUrl;
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
