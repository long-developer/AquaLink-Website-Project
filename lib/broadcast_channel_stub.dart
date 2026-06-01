import 'broadcast_channel.dart';

BroadcastSyncChannel createBroadcastSyncChannelImpl(
  void Function(String eventType, Map<String, dynamic> payload) onMessage,
) => _NoopBroadcastSyncChannel();

class _NoopBroadcastSyncChannel implements BroadcastSyncChannel {
  @override
  void dispose() {}

  @override
  void sendMessage(String eventType, Map<String, dynamic> payload) {}

  @override
  Map<String, dynamic>? loadPersistedState() => null;

  @override
  void savePersistedState(Map<String, dynamic> state) {}
}
