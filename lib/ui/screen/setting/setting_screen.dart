import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/dialog/app_logout_dialog.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:food_gram_app/utils/url_launch.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(loadingProvider);
    final state = ref.watch(settingViewModelProvider());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: Text(L10n.of(context).setting_app_bar),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(Icons.store),
                    title: Text(L10n.of(context).setting_check_version),
                    onPressed: (context) async {
                      final newVersion = NewVersionPlus();
                      final status = await newVersion.getVersionStatus();
                      if (status != null) {
                        newVersion.showUpdateDialog(
                          context: context,
                          versionStatus: status,
                          dialogTitle: L10n.of(context)
                              .setting_check_version_dialog_title,
                          dialogText:
                              '${L10n.of(context).setting_check_version_dialog_text_1}'
                              '\n'
                              '${L10n.of(context).setting_check_version_dialog_text_2}',
                          launchModeVersion: LaunchModeVersion.external,
                        );
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(
                      FontAwesomeIcons.twitter,
                      color: Colors.blue,
                    ),
                    title: Text(L10n.of(context).setting_developer),
                    onPressed: (context) {
                      LaunchUrl().openSNSUrl(
                        'twitter://user?screen_name=isekiryu',
                        'https://twitter.com/isekiryu',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(FontAwesomeIcons.github),
                    title: Text(L10n.of(context).setting_github),
                    onPressed: (context) {
                      LaunchUrl().open(
                        'https://github.com/iseruuuuu/food_gram_app',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.rate_review_outlined),
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    title: Text(L10n.of(context).setting_review),
                    onPressed: (context) async {
                      final inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        await inAppReview.requestReview();
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(Icons.share),
                    title: Text(L10n.of(context).setting_share),
                    onPressed: (context) {
                      if (Platform.isIOS) {
                        Share.share(
                          'https://apps.apple.com/hu/app/foodgram/id6474065183',
                        );
                      } else {
                        //TODO Androidは後の実装予定
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(L10n.of(context).setting_license),
                    onPressed: (context) {
                      context.pushNamed(RouterPath.license);
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(Icons.question_answer),
                    title: Text(L10n.of(context).setting_faq),
                    onPressed: (context) {
                      LaunchUrl().open(
                        'https://succinct-may-e5e.notion.site/FAQ-256ae853b9ec4209a04f561449de8c1d',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                    title: Text(L10n.of(context).setting_privacy_policy),
                    onPressed: (context) {
                      LaunchUrl().open(
                        'https://succinct-may-e5e.notion.site/fd5584426bf44c50bdb1eb4b376d165f',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: Icon(
                      Icons.call,
                      color: Colors.black,
                    ),
                    title: Text(L10n.of(context).setting_terms_of_use),
                    onPressed: (context) {
                      LaunchUrl().open(
                        'https://succinct-may-e5e.notion.site/a0ad75abf8244404b7a19cca0e2304f1',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: Icon(
                      Icons.mail,
                      color: Colors.black,
                    ),
                    title: Text(L10n.of(context).setting_contact),
                    onPressed: (context) {
                      LaunchUrl().open(
                        'https://forms.gle/mjucjntt3c2SZsUc7',
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: Icon(
                      Icons.account_balance,
                      color: Colors.black,
                    ),
                    title: Text(L10n.of(context).setting_tutorial),
                    onPressed: (context) {
                      context.pushNamed(RouterPath.settingTutorial);
                    },
                  ),
                  SettingsTile(
                    leading: Icon(
                      Icons.battery_4_bar_sharp,
                      color: Colors.black,
                    ),
                    title: Text(L10n.of(context).setting_battery),
                    trailing: Text(
                      state.battery,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(Icons.phone_android),
                    title: Text(L10n.of(context).setting_device),
                    trailing: Text(
                      state.model,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(
                      Platform.isAndroid ? Icons.android : Icons.apple,
                      color: Platform.isAndroid ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      Platform.isAndroid
                          ? L10n.of(context).setting_android
                          : L10n.of(context).setting_ios,
                    ),
                    trailing: Text(
                      state.sdk,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SettingsTile(
                    leading: Icon(Icons.settings, color: Colors.grey),
                    title: Text(L10n.of(context).setting_app_version),
                    trailing: Text(
                      state.version,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(L10n.of(context).setting_account),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    title: Text(
                      L10n.of(context).setting_logout_button,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AppLogoutDialog(
                            logout: () {
                              ref
                                  .read(settingViewModelProvider().notifier)
                                  .signOut()
                                  .then(
                                (value) {
                                  if (value) {
                                    if (mounted) {
                                      context.pushReplacementNamed(
                                        RouterPath.authentication,
                                      );
                                    }
                                  } else {
                                    openErrorSnackBar(context, 'ログアウト失敗');
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    title: Text(
                      L10n.of(context).setting_delete_account_button,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: (context) {
                      LaunchUrl()
                          .open(
                        'https://forms.gle/B2cG3FEynh1tbfUdA',
                      )
                          .then((value) {
                        if (!value) {
                          openErrorSnackBar(context, 'アカウント削除失敗');
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
            lightTheme: SettingsThemeData(
              settingsSectionBackground: Colors.grey.shade100,
              settingsListBackground: Colors.white,
              dividerColor: Colors.grey,
              leadingIconsColor: Colors.black,
            ),
            darkTheme: SettingsThemeData(
              settingsSectionBackground: Colors.grey.shade100,
              settingsListBackground: Colors.white,
              dividerColor: Colors.grey,
              leadingIconsColor: Colors.black,
            ),
          ),
          AppLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
    );
  }
}
