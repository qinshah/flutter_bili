import 'package:hive_ce/hive.dart';

part 'credentials.g.dart';

@HiveType(typeId: 0)
class Credentials extends HiveObject {
  @HiveField(0)
  final String accessKey;
  @HiveField(1)
  final String refreshToken;
  @HiveField(2)
  final String sessdata;
  @HiveField(3)
  final String csrf;
  @HiveField(4)
  final DateTime expiresAt;

  Credentials({
    required this.accessKey,
    required this.refreshToken,
    required this.sessdata,
    required this.csrf,
    required this.expiresAt,
  });
}
