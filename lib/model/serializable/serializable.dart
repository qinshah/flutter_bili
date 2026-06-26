import 'package:json_annotation/json_annotation.dart';

part 'serializable.g.dart';

abstract class Serializable {
  Map<String, dynamic> toJson();
}

@JsonSerializable()
class SerializableBool extends Serializable {
  final bool value;

  SerializableBool(this.value);

  factory SerializableBool.fromJson(Map<String, dynamic> json) =>
      _$SerializableBoolFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SerializableBoolToJson(this);
}
