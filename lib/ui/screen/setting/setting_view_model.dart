import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/setting/setting_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'setting_view_model.g.dart';

@riverpod
class SettingViewModel extends _$SettingViewModel {
  @override
  SettingState build({
    SettingState initState = const SettingState(),
  }) {
    return initState;
  }

  Loading get loading => ref.read(loadingProvider.notifier);

  Future<bool> logout() async {
    loading.state = true;
    try {
      await supabase.auth.signOut();
      return true;
    } on AuthException catch (error) {
      logger.e(error.message);
      return false;
    } on Exception catch (error) {
      logger.e(error);
      return false;
    } finally {
      loading.state = false;
    }
  }

  Future<bool> deleteAccount() async {
    loading.state = true;
    try {
      //TODO アカウントを削除する
      return true;
    } on AuthException catch (error) {
      logger.e(error.message);
      return false;
    } on Exception catch (error) {
      logger.e(error);
      return false;
    } finally {
      loading.state = false;
    }
  }
}
