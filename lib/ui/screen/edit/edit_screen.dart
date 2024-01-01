import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/ui/component/app_account_text_field.dart';
import 'package:food_gram_app/ui/component/app_icon.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/edit/edit_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';

class EditScreen extends ConsumerWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(editViewModelProvider().notifier);
    final state = ref.watch(editViewModelProvider());
    final loading = ref.watch(loadingProvider);
    return PopScope(
      canPop: !loading,
      child: GestureDetector(
        onTap: () => primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: !loading ? Colors.white : Colors.transparent,
            leading: !loading
                ? IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(
                      Icons.close,
                      size: 30,
                    ),
                  )
                : Container(),
            actions: [
              if (!loading)
                TextButton(
                  onPressed: () => ref
                      .read(editViewModelProvider().notifier)
                      .update()
                      .then((value) {
                    if (value) {
                      context.pop(true);
                    }
                  }),
                  child: Text(
                    '更新',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: loading ? Colors.grey : Colors.blueAccent,
                    ),
                  ),
                )
              else
                SizedBox(),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Wrap(
                        children: List.generate(
                          6,
                          (index) {
                            return AppIcon(
                              onTap: () => ref
                                  .read(editViewModelProvider().notifier)
                                  .selectIcon(index + 1),
                              number: index + 1,
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 30),
                      Divider(),
                      AppNameTextField(
                        title: '名前',
                        controller: controller.nameTextController,
                      ),
                      Divider(),
                      AppUserNameTextField(
                        controller: controller.useNameTextController,
                      ),
                      Divider(),
                      AppSelfIntroductionTextField(
                        controller: controller.selfIntroduceTextController,
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
              AppLoading(
                loading: loading,
                status: 'Loading...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
