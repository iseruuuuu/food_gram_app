import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_gram_app/core/data/supabase/auth/account_service.dart';
import 'package:food_gram_app/main.dart';
import 'package:food_gram_app/ui/screen/edit/edit_state.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_view_model.g.dart';

@riverpod
class EditViewModel extends _$EditViewModel {
  @override
  EditState build({
    EditState initState = const EditState(),
  }) {
    getProfile();
    return initState;
  }

  final nameTextController = TextEditingController();
  final useNameTextController = TextEditingController();
  final selfIntroduceTextController = TextEditingController();

  Loading get loading => ref.read(loadingProvider.notifier);
  final picker = ImagePicker();
  String uploadImage = '';
  Uint8List? imageBytes;

  Future<void> getProfile() async {
    await Future.delayed(Duration.zero);
    loading.state = true;
    final userId = supabase.auth.currentUser!.id;
    final data =
        await supabase.from('users').select().eq('user_id', userId).single();
    nameTextController.text = data['name'];
    useNameTextController.text = data['user_name'];
    selfIntroduceTextController.text = data['self_introduce'];
    state = state.copyWith(
      number: extractNumber(data['image']),
      initialImage: data['image'],
    );

    print(extractNumber(data['image']));

    loading.state = false;
  }

  String extractNumber(String path) {
    switch (path) {
      case 'assets/icon/icon0.png':
        return '0';
      case 'assets/icon/icon1.png':
        return '1';
      case 'assets/icon/icon2.png':
        return '2';
      case 'assets/icon/icon3.png':
        return '3';
      case 'assets/icon/icon4.png':
        return '4';
      case 'assets/icon/icon5.png':
        return '5';
      case 'assets/icon/icon6.png':
        return '6';
    }
    return '0';
  }

  Future<bool> update() async {
    primaryFocus?.unfocus();
    loading.state = true;
    final result = await ref.read(accountServiceProvider).update(
          name: nameTextController.text,
          userName: useNameTextController.text,
          selfIntroduce: selfIntroduceTextController.text,
          image: state.number.toString(),
          uploadImage: uploadImage,
          imageBytes: imageBytes,
        );
    result.when(
      success: (_) {
        return true;
      },
      failure: (error) {
        state = state.copyWith(status: error.toString());
        return false;
      },
    );
    loading.state = false;
    return true;
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
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
      state = state.copyWith(
        uploadImage: image.path,
        isSelectedIcon: false,
      );
      return true;
    } on PlatformException catch (error) {
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
      imageBytes = await image.readAsBytes();
      uploadImage = image.name;
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
