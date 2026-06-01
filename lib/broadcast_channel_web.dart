import 'dart:convert';
import 'dart:html';
import 'broadcast_channel.dart';

class _WebBroadcastSyncChannel implements BroadcastSyncChannel {
  final BroadcastChannel _channel;
  final void Function(String eventType, Map<String, dynamic> payload)
  _onMessage;

  _WebBroadcastSyncChannel(this._onMessage)
    : _channel = BroadcastChannel('aqualink_sync_channel') {
    _channel.onMessage.listen((event) {
      try {
        final payload = jsonDecode(event.data as String);
        final eventType = payload['type'] as String?;
        final body = payload['payload'] as Map<String, dynamic>?;
        if (eventType != null && body != null) {
          _onMessage(eventType, body);
        }
      } catch (_) {
        // ignore malformed sync payloads
      }
    });
  }

  @override
  void dispose() {
    _channel.close();
  }

  @override
  void sendMessage(String eventType, Map<String, dynamic> payload) {
    final message = jsonEncode({'type': eventType, 'payload': payload});
    _channel.postMessage(message);
  }

  @override
  Map<String, dynamic>? loadPersistedState() {
    try {
      final text = window.localStorage['aqualink_persisted_state'];
      if (text == null || text.isEmpty) return null;
      final decoded = jsonDecode(text) as Map<String, dynamic>;
      return decoded;
    } catch (_) {
      return null;
    }
  }

  @override
  void savePersistedState(Map<String, dynamic> state) {
    try {
      window.localStorage['aqualink_persisted_state'] = jsonEncode(state);
    } catch (_) {
      // ignore local storage failures
    }
  }
}

BroadcastSyncChannel createBroadcastSyncChannelImpl(
  void Function(String eventType, Map<String, dynamic> payload) onMessage,
) => _WebBroadcastSyncChannel(onMessage);
