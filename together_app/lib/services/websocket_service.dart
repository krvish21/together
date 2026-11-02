import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/api_config.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic> data);

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _isConnected = false;

  String? _coupleId;
  String? _partner;

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  bool get isConnected => _isConnected;

  void connect({required String coupleId, required String partner}) {
    _coupleId = coupleId;
    _partner = partner;
    _initChannel();
  }

  void _initChannel() {
    if (_isConnecting || _coupleId == null) return;
    _isConnecting = true;

    try {
      final wsUrl = ApiConfig.wsUrl;
      debugPrint('[WS] Connecting to $wsUrl ...');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _subscription?.cancel();
      _subscription = _channel!.stream.listen(
        (data) {
          _isConnected = true;
          _isConnecting = false;
          try {
            final parsed = jsonDecode(data.toString());
            debugPrint('[WS Recv] ${parsed['type']}');
            _eventController.add(Map<String, dynamic>.from(parsed));
          } catch (e) {
            debugPrint('[WS Parse Error] $e');
          }
        },
        onError: (err) {
          debugPrint('[WS Error] $err');
          _onDisconnected();
        },
        onDone: () {
          debugPrint('[WS Done]');
          _onDisconnected();
        },
      );

      // Send JOIN_ROOM message
      send({
        'type': 'JOIN_ROOM',
        'coupleId': _coupleId,
        'partner': _partner,
      });

      _isConnected = true;
      _isConnecting = false;
    } catch (e) {
      debugPrint('[WS Connect Exception] $e');
      _onDisconnected();
    }
  }

  void send(Map<String, dynamic> message) {
    if (_channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        debugPrint('[WS Send Error] $e');
      }
    }
  }

  void sendInteraction(String action, [Map<String, dynamic>? payload]) {
    send({
      'type': 'INTERACTION_EVENT',
      'coupleId': _coupleId,
      'partner': _partner,
      'action': action,
      'payload': payload ?? {},
    });
  }

  void _onDisconnected() {
    _isConnected = false;
    _isConnecting = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;

    // Schedule reconnect
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (_coupleId != null) {
        debugPrint('[WS] Reconnecting...');
        _initChannel();
      }
    });
  }

  void updatePartner(String newPartnerRole) {
    _partner = newPartnerRole;
    if (_isConnected && _coupleId != null) {
      send({
        'type': 'JOIN_ROOM',
        'coupleId': _coupleId,
        'partner': _partner,
      });
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    _isConnecting = false;
    _coupleId = null;
    _partner = null;
  }
}
