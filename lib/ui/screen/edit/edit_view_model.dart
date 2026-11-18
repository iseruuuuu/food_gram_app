import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/model/result.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/auth/services/account_service.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/utils/instagram_username.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/ui/screen/edit/edit_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_view_model.g.dart';

@riverpod
class EditViewModel extends _$EditViewModel {
  @override
  EditState build({
    EditState? initState,
  }) {
    getProfile();
    return initState ?? const EditState();
  }

  static const invalidInstagramStatus = 'invalid_instagram';

  final logger = Logger();

  final nameTextController = TextEditingController();
  final selfIntroduceTextController = TextEditingController();
  final instagramTextController = TextEditingController();

  Loading get _loading => ref.read(loadingProvider.notifier);
  var _uploadImage = '';
  Uint8List? _imageBytes;

  Future<void> getProfile() async {
    await Future<void>.delayed(Duration.zero);
    _loading.state = true;
    final userId = ref.watch(currentUserProvider);
    final supabase = ref.watch(supabaseProvider);
    final data = await supabase
        .from('users')
        .select()
        .eq('user_id', userId!)
        .single();
    final user = Users.fromJson(data);
    nameTextController.text = user.name;
    selfIntroduceTextController.text = user.selfIntroduce;
    instagramTextController.text = user.instagram;
    state = state.copyWith(
      number: int.parse(extractNumber(user.image)),
      initialImage: user.image,
      isSubscribe: user.isSubscribe,
      user: user,
    );
    _loading.state = false;
  }

  /// 購入後に入力中の名前・自己紹介・アイコンを残したままサブスク状態だけ更新する。
  Future<void> refreshSubscription() async {
    state = state.copyWith(
      isSubscribe: true,
      user: state.user?.copyWith(isSubscribe: true),
    );
    await ref.read(isSubscribeProvider.notifier).refresh();
  }

  String extractNumber(String path) {
    final regExp = RegExp(r'\d+');
    final Match? match = regExp.firstMatch(path);
    return match?.group(0) ?? '';
  }

  Future<bool> update() async {
    primaryFocus?.unfocus();
    final isPremium =
        state.isSubscribe || (ref.read(isSubscribeProvider).value ?? false);
    String? instagram;
    if (isPremium) {
      final normalized = normalizeInstagramUsername(
        instagramTextController.text,
      );
      if (normalized == null) {
        state = state.copyWith(status: invalidInstagramStatus);
        return false;
      }
      instagramTextController.text = normalized;
      instagram = normalized;
    }
    _loading.state = true;
    final result = await ref
        .read(accountServiceProvider)
        .update(
          name: nameTextController.text,
          selfIntroduce: selfIntroduceTextController.text,
          image: state.number.toString(),
          instagram: instagram,
          uploadImage: _uploadImage,
          imageBytes: _imageBytes,
        );
    var success = false;
    await result.when(
      success: (_) async {
        await getProfile();
        success = true;
      },
      failure: (error) {
        state = state.copyWith(status: error.toString());
        success = false;
      },
    );
    _loading.state = false;
    return success;
  }

  void selectIcon(int number) {
    state = state.copyWith(
      number: number,
      uploadImage: '',
      isSelectedIcon: true,
    );
  }

  Future<bool> camera() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return false;
      }
      _imageBytes = await image.readAsBytes();
      _uploadImage = image.name;
      state = state.copyWith(
        uploadImage: image.path,
        isSelectedIcon: false,
      );
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> album() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxHeight: 960,
        maxWidth: 960,
        imageQuality: 100,
      );
      if (image == null) {
        return false;
      }
      _imageBytes = await image.readAsBytes();
      _uploadImage = image.name;
      state = state.copyWith(
        uploadImage: image.path,
        isSelectedIcon: false,
      );
      return true;
    } on PlatformException catch (error) {
      logger.e(error.message);
      return false;
    }
  }
}
