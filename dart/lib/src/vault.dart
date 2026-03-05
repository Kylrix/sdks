import 'client.dart';

/// Kylrix.Vault: The Secure State Store Module.
/// Domain: vault.kylrix.space
class KylrixVault {
  final Kylrix _sdk;

  KylrixVault(this._sdk);

  /// Retrieves all credentials for a user.
  Future<dynamic> getCredentials({
    required String databaseId,
    required String tableId,
    List<String> queries = const [],
  }) async {
    return await _sdk.listRows(
      databaseId: databaseId,
      tableId: tableId,
      queries: queries,
    );
  }

  /// Securely saves a credential to the vault.
  Future<dynamic> saveCredential({
    required String databaseId,
    required String tableId,
    required Map<String, dynamic> encryptedData,
  }) async {
    return await _sdk.createRow(
      databaseId: databaseId,
      tableId: tableId,
      data: encryptedData,
    );
  }
}
