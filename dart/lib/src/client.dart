import 'package:appwrite/appwrite.dart';

class Kylrix {
  late final Client _client;
  late final Account _account;
  late final Databases _databases;

  Kylrix({required String endpoint, required String project}) {
    _client = Client().setEndpoint(endpoint).setProject(project);

    _account = Account(_client);
    _databases = Databases(_client);
  }

  Account get account => _account;
  Databases get databases => _databases;

  String getDomain(String subdomain, {String baseDomain = 'kylrix.space'}) {
    return 'https://$subdomain.$baseDomain';
  }
}
