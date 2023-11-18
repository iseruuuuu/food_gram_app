import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/component/app_edit_text_field.dart';
import 'package:food_gram_app/component/app_elevated_button.dart';
import 'package:food_gram_app/component/app_icon.dart';
import 'package:food_gram_app/component/app_loading.dart';
import 'package:food_gram_app/provider/loading.dart';
import 'package:food_gram_app/screen/authentication/new_account_view_model.dart';

class NewAccountScreen extends ConsumerWidget {
  const NewAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final controller = ref.watch(newAccountViewModelProvider().notifier);
    final state = ref.watch(newAccountViewModelProvider());
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage:
                        AssetImage('assets/icon/icon${state.number}.png'),
                    radius: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'アイコンの設定',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Wrap(
                    children: List.generate(
                      6,
                      (index) {
                        return AppIcon(
                          onTap: () => ref
                              .read(newAccountViewModelProvider().notifier)
                              .selectIcon(index + 1),
                          number: index + 1,
                        );
                      },
                    ),
                  ),
                  AppEditTextField(
                    title: '名前',
                    controller: controller.nameTextController,
                  ),
                  AppUserNameTextField(
                    controller: controller.userNameTextController,
                  ),
                  AppElevatedButton(
                    onPressed: () => ref
                        .read(newAccountViewModelProvider().notifier)
                        .setUsers(context),
                    title: '登録',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      state.loginStatus,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppLoading(loading: loading),
          ],
        ),
      ),
    );
  }
}
