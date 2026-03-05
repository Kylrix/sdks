import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'pulse.dart';

/// Kylrix Ecosystem Discovery
class EcosystemConfig {
  static const String domain = 'kylrix.space';
  static const String defaultEndpoint = 'https://cloud.appwrite.io/v1';

  static const Map<String, String> subdomains = {
    'accounts': 'accounts',
    'vault': 'vault',
    'note': 'note',
    'flow': 'flow',
    'connect': 'connect',
  };

  static String getUrl(String subdomain, {String path = ''}) {
    final sub = subdomains[subdomain] ?? subdomain;
    final url = 'https://$sub.$domain';
    if (path.isEmpty) return url;
    return path.startsWith('/') ? '$url$path' : '$url/$path';
  }
}

/// Standardized TableDB Terminology
class TableDB {
  static String getEventPath(String databaseId, String tableId,
      {String? rowId}) {
    return 'databases.$databaseId.tables.$tableId${rowId != null ? '.rows.$rowId' : '.rows'}';
  }
}

/// Kylrix Design System
class KylrixTheme {
  static const String brandColor = '#6366F1';
  static const String creamyColor = '#FDFCFB';
  static const String glassColor = 'rgba(255, 255, 255, 0.7)';

  static const String headingFont = 'Clash Display';
  static const String uiFont = 'Satoshi';
  static const String monoFont = 'JetBrains Mono';

  static const double blurAmount = 12.0;
  static const double borderRadius = 16.0;
}

class Kylrix {
  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  Realtime? _realtime;
  KylrixPulse? _pulse;

  final theme = KylrixTheme();

  Kylrix({
    String endpoint = EcosystemConfig.defaultEndpoint,
    required String project,
  }) {
    _client = Client().setEndpoint(endpoint).setProject(project);
    _account = Account(_client);
    _databases = Databases(_client);
  }

  Account get account => _account;
  Databases get databases => _databases;

  Realtime get realtime {
    _realtime ??= Realtime(_client);
    return _realtime!;
  }

  KylrixPulse get pulse {
    _pulse ??= KylrixPulse(realtime);
    return _pulse!;
  }

  /// Standardized listRows (formerly listDocuments)
  Future<models.DocumentList> listRows({
    required String databaseId,
    required String tableId,
    List<String> queries = const [],
  }) async {
    return await _databases.listDocuments(
      databaseId: databaseId,
      collectionId: tableId,
      queries: queries,
    );
  }

  /// Standardized getRow (formerly getDocument)
  Future<models.Document> getRow({
    required String databaseId,
    required String tableId,
    required String rowId,
  }) async {
    return await _databases.getDocument(
      databaseId: databaseId,
      collectionId: tableId,
      documentId: rowId,
    );
  }

  /// Standardized createRow (formerly createDocument)
  Future<models.Document> createRow({
    required String databaseId,
    required String tableId,
    required Map<String, dynamic> data,
    String rowId = 'unique()',
    List<String>? permissions,
  }) async {
    return await _databases.createDocument(
      databaseId: databaseId,
      collectionId: tableId,
      documentId: rowId == 'unique()' ? ID.unique() : rowId,
      data: data,
      permissions: permissions,
    );
  }

  /// Standardized updateRow (formerly updateDocument)
  Future<models.Document> updateRow({
    required String databaseId,
    required String tableId,
    required String rowId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    return await _databases.updateDocument(
      databaseId: databaseId,
      collectionId: tableId,
      documentId: rowId,
      data: data,
      permissions: permissions,
    );
  }

  /// Standardized deleteRow (formerly deleteDocument)
  Future<dynamic> deleteRow({
    required String databaseId,
    required String tableId,
    required String rowId,
  }) async {
    return await _databases.deleteDocument(
      databaseId: databaseId,
      collectionId: tableId,
      documentId: rowId,
    );
  }
}
