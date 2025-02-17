import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/app_icon.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_text_field.dart';
import 'package:food_gram_app/ui/screen/new_account/new_account_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
                    Gap(10),
                    Text(
                      L10n.of(context).settingsIcon,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    Gap(10),
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
                    Gap(30),
                    AppNameTextField(
                      controller: controller.nameTextController,
                    ),
                    Gap(30),
                    AppUserNameTextField(
                      controller: controller.userNameTextController,
                    ),
                    Gap(30),
                    AppElevatedButton(
                      onPressed: () {
                        ref
                            .read(newAccountViewModelProvider().notifier)
                            .setUsers()
                            .then((value) {
                          if (value) {
                            context.pushReplacementNamed(RouterPath.tab);
                          }
                        });
                      },
                      title: L10n.of(context).registerButton,
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
            ),
            AppLoading(
              loading: loading,
              status: 'Loading...',
            ),
          ],
        ),
      ),
    );
  }
}
