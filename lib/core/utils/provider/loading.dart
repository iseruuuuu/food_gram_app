import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'loading.g.dart';

@riverpod
class Loading extends _$Loading {
  @override
  bool build() => false;

  bool isLoading({required bool value}) {
    return state = value;
  }
}
