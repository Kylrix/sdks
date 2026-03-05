import 'client.dart';
import 'pulse.dart';

/// Kylrix.Connect: The Communication Relay Module.
/// Domain: connect.kylrix.space
class KylrixConnect {
  final Kylrix _sdk;

  KylrixConnect(this._sdk);

  /// Sends a message to a conversation.
  Future<dynamic> sendMessage({
    required String databaseId,
    required String tableId,
    required String conversationId,
    required String senderId,
    required String type, // 'text', 'image', 'video', 'call_signal'
    String? content,
    List<String>? attachments,
  }) async {
    return await _sdk.createRow(
      databaseId: databaseId,
      tableId: tableId,
      data: {
        'conversationId': conversationId,
        'senderId': senderId,
        'type': type,
        'content': content,
        'attachments': attachments ?? [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Subscribes to new messages in a conversation.
  Stream<Map<String, dynamic>> onMessage({
    required String databaseId,
    required String tableId,
    required String conversationId,
  }) {
    // This uses a query-based realtime subscription pattern
    // For now, it returns the raw stream of the table rows
    return _sdk.pulse.subscribeToRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: '*', // Subscribe to all new rows in this table
    );
  }

  /// Listens to incoming calls via the Pulse system.
  Stream<PulsePayload> onIncomingCall({
    required String databaseId,
    required String pulseTableId,
  }) {
    return _sdk.pulse.on(PulseEvent.callIncoming,
        databaseId: databaseId, pulseTableId: pulseTableId);
  }
}
