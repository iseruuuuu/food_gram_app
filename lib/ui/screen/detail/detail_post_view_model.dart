import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/detail/detail_post_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    try {
      await supabase.from('posts').delete().eq('id', id);
      return true;
    } on PostgrestException catch (_) {
      return false;
    }
  }
}
