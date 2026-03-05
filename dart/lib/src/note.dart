import 'client.dart';

/// Kylrix.Note: The Intelligence Layer Module.
/// Domain: note.kylrix.space
class KylrixNote {
  final Kylrix _sdk;

  KylrixNote(this._sdk);

  /// Saves a note revision.
  Future<dynamic> saveRevision({
    required String databaseId,
    required String tableId,
    required String noteId,
    required String userId,
    required String content,
    String? title,
    String? diff,
    String cause = 'manual',
  }) async {
    return await _sdk.createRow(
      databaseId: databaseId,
      tableId: tableId,
      data: {
        'noteId': noteId,
        'userId': userId,
        'content': content,
        'title': title,
        'diff': diff,
        'cause': cause,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Adds a tag to a note.
  Future<dynamic> addTag({
    required String databaseId,
    required String tableId,
    required String noteId,
    required String tagName,
  }) async {
    final note = await _sdk.getRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: noteId,
    );

    final List<String> tags = List<String>.from(note.data['tags'] ?? []);
    if (!tags.contains(tagName)) {
      tags.add(tagName);
    }

    return await _sdk.updateRow(
      databaseId: databaseId,
      tableId: tableId,
      rowId: noteId,
      data: {'tags': tags},
    );
  }
}
