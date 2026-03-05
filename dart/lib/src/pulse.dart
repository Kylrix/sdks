import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'client.dart';

/// Pulse signals used across the ecosystem.
enum PulseEvent {
  callIncoming,
  notificationNew,
  taskUpdate,
  vaultUnlock,
  unknown
}

/// A standardized payload for Kylrix Pulse events.
class PulsePayload {
  final PulseEvent type;
  final Map<String, dynamic> data;
  final String? timestamp;

  PulsePayload({
    required this.type,
    required this.data,
    this.timestamp,
  });

  factory PulsePayload.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = PulseEvent.values.firstWhere(
      (e) => e.toString().split('.').last == _toCamelCase(typeStr ?? ''),
      orElse: () => PulseEvent.unknown,
    );
    return PulsePayload(
      type: type,
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] as String?,
    );
  }

  static String _toCamelCase(String s) {
    final parts = s.split('.');
    if (parts.length < 2) return s;
    return parts[0] + parts[1][0].toUpperCase() + parts[1].substring(1);
  }
}

/// High-level Pulse Orchestrator for Flutter/Dart Ecosystem Gossip.
class KylrixPulse {
  final Realtime _realtime;

  KylrixPulse(this._realtime);

  /// Subscribes to a standardized TableDB row event.
  /// Returns a [Stream] of the row payload.
  Stream<Map<String, dynamic>> subscribeToRow({
    required String databaseId,
    required String tableId,
    required String rowId,
  }) {
    final channel = TableDB.getEventPath(databaseId, tableId, rowId: rowId);
    final subscription = _realtime.subscribe([channel]);

    final controller = StreamController<Map<String, dynamic>>();

    subscription.stream.listen((event) {
      controller.add(event.payload as Map<String, dynamic>);
    },
        onDone: () => controller.close(),
        onError: (e) => controller.addError(e));

    return controller.stream;
  }

  /// Listens to ecosystem-wide "Pulse" signals.
  /// Standardized events (e.g., 'call.incoming') are emitted as [PulsePayload].
  Stream<PulsePayload> on(
    PulseEvent event, {
    required String databaseId,
    required String pulseTableId,
  }) {
    final channel = TableDB.getEventPath(databaseId, pulseTableId);
    final subscription = _realtime.subscribe([channel]);

    final controller = StreamController<PulsePayload>();

    subscription.stream.listen((response) {
      final payload =
          PulsePayload.fromJson(response.payload as Map<String, dynamic>);
      if (payload.type == event || event == PulseEvent.unknown) {
        controller.add(payload);
      }
    },
        onDone: () => controller.close(),
        onError: (e) => controller.addError(e));

    return controller.stream;
  }
}
