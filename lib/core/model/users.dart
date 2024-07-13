import 'package:freezed_annotation/freezed_annotation.dart';

part 'users.freezed.dart';
part 'users.g.dart';

@freezed
class Users with _$Users {
  const factory Users({
    required int id,
    required String name,
    required String userName,
    required String selfIntroduce,
    required String image,
    required DateTime createdAt,
    required DateTime updateTime,
    required String userId,
    required int exchangedPoint,
  }) = _Users;

  const Users._();

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);
}
