import 'package:hive_ce/hive_ce.dart';

part 'setting_m.g.dart';

@HiveType(typeId: 2)
enum PlayerKernel {
  @HiveField(0)
  mpv,
  @HiveField(1)
  mdk,
}
