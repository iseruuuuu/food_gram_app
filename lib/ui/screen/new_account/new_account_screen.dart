import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
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
    ref.listen(newAccountViewModelProvider(), (previous, current) {
      if (current.loginStatus.isNotEmpty &&
          previous?.loginStatus != current.loginStatus) {
        var message = '';
        switch (current.loginStatus) {
          case 'account_registration_error':
            message = L10n.of(context).accountRegistrationError;
            SnackBarHelper().openError(context, '', message);
            break;
          case 'required_info_missing':
            message = L10n.of(context).requiredInfoMissing;
            SnackBarHelper().openError(context, '', message);
            break;
          default:
            message = current.loginStatus;
        }
      }
    });

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Gap(20),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          AssetImage('assets/icon/icon${state.number}.png'),
                      radius: 60,
                    ),
                    const Gap(10),
                    Text(
                      L10n.of(context).settingsIcon,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const Gap(10),
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
                    const Gap(30),
                    AppNameTextField(
                      controller: controller.nameTextController,
                    ),
                    const Gap(20),
                    AppUserNameTextField(
                      controller: controller.userNameTextController,
                    ),
                    const Gap(20),
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
                    const Gap(20),
                    Text(
                      L10n.of(context).newAccountImportantTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      L10n.of(context).newAccountImportant,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
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
