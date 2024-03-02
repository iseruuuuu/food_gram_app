import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:food_gram_app/utils/mixin/dialog_mixin.dart';
import 'package:food_gram_app/utils/mixin/snack_bar_mixin.dart';
import 'package:food_gram_app/utils/mixin/url_launcher_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends ConsumerState<SettingScreen>
    with UrlLauncherMixin, DialogMixin, SnackBarMixin {
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
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.store),
                  //   title: const Text('最新のバージョンを確認する'),
                  //   onPressed: (context) {},
                  // ),
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
                      openSNSUrl(
                        'twitter://user?screen_name=isekiryu',
                        'https://twitter.com/isekiryu',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                      launcherUrl(
                        'https://github.com/iseruuuuu/food_gram_app',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.rate_review_outlined),
                  //   title: const Text('レビューを書く'),
                  //   onPressed: (context) {},
                  // ),
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.share),
                  //   title: const Text('アプリを紹介する'),
                  //   onPressed: (context) {},
                  // ),
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.star),
                  //   title: const Text('このアプリを応援する'),
                  //   onPressed: (context) {},
                  // ),
                  SettingsTile.navigation(
                    trailing: Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                    ),
                    leading: const Icon(Icons.question_answer),
                    title: Text(L10n.of(context).setting_faq),
                    onPressed: (context) {
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/FAQ-256ae853b9ec4209a04f561449de8c1d',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/fd5584426bf44c50bdb1eb4b376d165f',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/a0ad75abf8244404b7a19cca0e2304f1',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                      launcherUrl(
                        'https://forms.gle/mjucjntt3c2SZsUc7',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
                        }
                      });
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
                      openLogOutDialog(
                        context: context,
                        logout: () => ref
                            .read(settingViewModelProvider().notifier)
                            .signOut()
                            .then((value) {
                          if (value) {
                            if (mounted) {
                              context.pushReplacementNamed(
                                RouterPath.authentication,
                              );
                            }
                          } else {
                            openErrorSnackBar(context);
                          }
                        }),
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
                      launcherUrl(
                        'https://forms.gle/B2cG3FEynh1tbfUdA',
                      ).then((value) {
                        if (!value) {
                          openErrorSnackBar(context);
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
