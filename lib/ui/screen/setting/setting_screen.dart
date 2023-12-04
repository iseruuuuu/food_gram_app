import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:food_gram_app/utils/mixin/dialog_mixin.dart';
import 'package:food_gram_app/utils/mixin/url_launcher_mixin.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:go_router/go_router.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends ConsumerWidget with UrlLauncherMixin, DialogMixin {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    return Scaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      appBar: AppAppBar(),
      body: Stack(
        children: [
          SettingsList(
            sections: [
              SettingsSection(
                title: const Text('基本設定'),
                tiles: <SettingsTile>[
                  // SettingsTile.navigation(
                  //   leading: const Icon(Icons.store),
                  //   title: const Text('最新のバージョンを確認する'),
                  //   onPressed: (context) {},
                  // ),
                  SettingsTile.navigation(
                    leading: const Icon(
                      FontAwesomeIcons.twitter,
                      color: Colors.blue,
                    ),
                    title: const Text('開発者'),
                    onPressed: (context) {
                      openSNSUrl(
                        'twitter://user?screen_name=isekiryu',
                        'https://twitter.com/isekiryu',
                        context,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(FontAwesomeIcons.github),
                    title: const Text('コントレビュートする'),
                    onPressed: (context) {
                      launcherUrl(
                        'https://github.com/iseruuuuu/food_gram_app',
                        context,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.account_balance_wallet_outlined),
                    title: const Text('ライセンス'),
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
                    leading: const Icon(Icons.question_answer),
                    title: const Text('FAQ'),
                    onPressed: (context) {
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/FAQ-256ae853b9ec4209a04f561449de8c1d',
                        context,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.lock),
                    title: const Text('プライバシーポリシー'),
                    onPressed: (context) {
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/fd5584426bf44c50bdb1eb4b376d165f',
                        context,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.call),
                    title: const Text('利用規約'),
                    onPressed: (context) {
                      launcherUrl(
                        'https://succinct-may-e5e.notion.site/a0ad75abf8244404b7a19cca0e2304f1',
                        context,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.mail),
                    title: const Text('お問い合わせ'),
                    onPressed: (context) {
                      launcherUrl(
                        'https://forms.gle/mjucjntt3c2SZsUc7',
                        context,
                      );
                    },
                  ),
                  SettingsTile(
                    title: const Text('アプリのバージョン'),
                    trailing: const Text('1.0.0'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('アカウント'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout),
                    title: const Text(
                      'ログアウト',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: (context) {
                      openLogOutDialog(
                        context: context,
                        logout: () => ref
                            .read(settingViewModelProvider().notifier)
                            .logout()
                            .then(
                          (value) {
                            if (value) {
                              //TODO 以下のwarningを治す
                              // Unhandled Exception: Looking up a deactivated widget's ancestor is unsafe.
                              // At this point the state of the widget's element tree is no longer stable.
                              // To safely refer to a widget's ancestor in its dispose() method, save a reference to the ancestor by calling dependOnInheritedWidgetOfExactType() in the widget's didChangeDependencies() method.
                              context.pushReplacementNamed(
                                RouterPath.authentication,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text(
                      'アカウントの削除',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: (context) {
                      openDeleteAccountDialog(
                        context: context,
                        deleteAccount: () => ref
                            .read(settingViewModelProvider().notifier)
                            .deleteAccount()
                            .then((value) {
                          if (value) {
                            context.pushReplacementNamed(
                              RouterPath.authentication,
                            );
                          }
                        }),
                      );
                    },
                  ),
                ],
              ),
            ],
            lightTheme: const SettingsThemeData(
              settingsListBackground: CupertinoColors.extraLightBackgroundGray,
              dividerColor: Colors.grey,
              leadingIconsColor: Colors.black,
            ),
            darkTheme: const SettingsThemeData(
              settingsListBackground: Colors.white,
            ),
          ),
          AppLoading(loading: loading),
        ],
      ),
    );
  }
}
