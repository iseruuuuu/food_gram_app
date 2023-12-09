import 'package:food_gram_app/service/database_service.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'detail_post_view_model.g.dart';

@riverpod
class DetailPostViewModel extends _$DetailPostViewModel {
  @override
  DetailPostState build({
    DetailPostState initState = const DetailPostState(),
  }) {
    return initState;
  }

  Future<bool> delete(int id) async {
    final result = await ref.read(databaseServiceProvider).delete(id);
    result.when(success: (_) {
      state = state.copyWith(isSuccess: true);
    }, failure: (_) {
      state = state.copyWith(isSuccess: false);
    });
    return state.isSuccess;
  }
}
