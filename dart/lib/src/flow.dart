import 'client.dart';
import 'pulse.dart';

/// Kylrix.Flow: The Action Engine Module.
/// Domain: flow.kylrix.space
class KylrixFlow {
  final Kylrix _sdk;

  KylrixFlow(this._sdk);

  /// Creates a new task in the Flow engine.
  Future<dynamic> createTask({
    required String databaseId,
    required String tableId,
    required String title,
    required String userId,
    String? description,
    String? status,
    String? priority,
    String? dueDate,
    List<String>? tags,
  }) async {
    return await _sdk.createRow(
      databaseId: databaseId,
      tableId: tableId,
      data: {
        'title': title,
        'userId': userId,
        'description': description,
        'status': status ?? 'pending',
        'priority': priority ?? 'medium',
        'dueDate': dueDate,
        'tags': tags ?? [],
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Listens to task updates via the Pulse system.
  Stream<PulsePayload> onTaskUpdate({
    required String databaseId,
    required String pulseTableId,
  }) {
    return _sdk.pulse.on(PulseEvent.taskUpdate,
        databaseId: databaseId, pulseTableId: pulseTableId);
  }
}
