import 'package:hive_ce/hive.dart';

part 'user_m.g.dart';

@HiveType(typeId: 0)
class UserM extends HiveObject {
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
  @HiveField(5)
  final String cookies;

  UserM({
    required this.accessKey,
    required this.refreshToken,
    required this.sessdata,
    required this.csrf,
    required this.expiresAt,
    required this.cookies,
  });
}
