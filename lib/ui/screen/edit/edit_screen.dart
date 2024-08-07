import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_icon.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/edit/edit_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:gap/gap.dart';
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
                    onPressed: () async {
                      primaryFocus?.unfocus();
                      await Future.delayed(Duration(milliseconds: 100));
                      context.pop();
                    },
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
                    L10n.of(context).editUpdateButton,
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
                          L10n.of(context).settingsIcon,
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
                      Gap(30),
                      AppNameTextField(
                        controller: controller.nameTextController,
                      ),
                      Gap(30),
                      AppUserNameTextField(
                        controller: controller.useNameTextController,
                      ),
                      Gap(30),
                      AppSelfIntroductionTextField(
                        controller: controller.selfIntroduceTextController,
                      ),
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
