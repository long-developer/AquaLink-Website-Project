import 'broadcast_channel_stub.dart'
    if (dart.library.html) 'broadcast_channel_web.dart';

abstract class BroadcastSyncChannel {
  void sendMessage(String eventType, Map<String, dynamic> payload);
  void dispose();
  Map<String, dynamic>? loadPersistedState();
  void savePersistedState(Map<String, dynamic> state);
}

BroadcastSyncChannel createBroadcastSyncChannel(
  void Function(String eventType, Map<String, dynamic> payload) onMessage,
) => createBroadcastSyncChannelImpl(onMessage);
