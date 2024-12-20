import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/data/admob/admob_banner.dart';
import 'package:food_gram_app/core/data/purchase/subscription_provider.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_setting_tile.dart';
import 'package:food_gram_app/ui/component/dialog/app_dialog.dart';
import 'package:food_gram_app/ui/component/dialog/app_logout_dialog.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:food_gram_app/utils/provider/loading.dart';
import 'package:food_gram_app/utils/share.dart';
import 'package:food_gram_app/utils/snack_bar_manager.dart';
import 'package:food_gram_app/utils/url_launch.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
    final l10n = L10n.of(context);
    final subscriptionState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Gap(12),
                      Wrap(
                        children: [
                          AppSettingTile(
                            icon: FontAwesomeIcons.twitter,
                            color: Colors.blue,
                            title: l10n.settingsDeveloper,
                            onTap: () {
                              LaunchUrl()
                                  .openSNSUrl('https://x.com/FoodGram_dev');
                            },
                          ),
                          AppSettingTile(
                            icon: FontAwesomeIcons.github,
                            title: l10n.settingsGithub,
                            onTap: () {
                              LaunchUrl().open(
                                'https://github.com/iseruuuuu/food_gram_app',
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.verified,
                            color: Colors.blue,
                            title: l10n.settingsLicense,
                            onTap: () {
                              context.pushNamed(RouterPath.license);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.share,
                            color: Colors.lightBlue,
                            title: l10n.settingsShareApp,
                            onTap: () {
                              if (Platform.isIOS) {
                                shareNormal(
                                  'https://apps.apple.com/hu/app/foodgram/id6474065183',
                                );
                              } else {
                                // TODO: Androidは後の実装予定
                              }
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.rate_review_outlined,
                            color: Colors.indigoAccent,
                            title: l10n.settingsReview,
                            onTap: () {
                              ref
                                  .read(settingViewModelProvider().notifier)
                                  .review();
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.system_update,
                            color: Colors.deepPurpleAccent,
                            title: l10n.settingsCheckVersion,
                            onTap: () {
                              ref
                                  .read(settingViewModelProvider().notifier)
                                  .checkNewVersion(context);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.help_outline,
                            color: Colors.lightBlue,
                            size: 32,
                            title: l10n.settingsFaq,
                            onTap: () {
                              LaunchUrl().open(
                                'https://succinct-may-e5e.notion.site/FAQ-256ae853b9ec4209a04f561449de8c1d',
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.security,
                            color: Colors.indigoAccent,
                            title: l10n.settingsPrivacyPolicy,
                            onTap: () {
                              LaunchUrl().open(
                                'https://succinct-may-e5e.notion.site/fd5584426bf44c50bdb1eb4b376d165f',
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.assignment,
                            color: Colors.deepPurpleAccent,
                            title: l10n.settingsTermsOfUse,
                            onTap: () {
                              LaunchUrl().open(
                                'https://succinct-may-e5e.notion.site/a0ad75abf8244407b7a19cca0e2304f1',
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.chat,
                            size: 32,
                            color: Colors.lightBlue,
                            title: l10n.settingsContact,
                            onTap: () {
                              LaunchUrl().open(
                                'https://forms.gle/mjucjntt3c2SZsUc7',
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.school,
                            size: 32,
                            color: Colors.indigoAccent,
                            title: l10n.settingsTutorial,
                            onTap: () {
                              context.pushNamed(RouterPath.settingTutorial);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.copyright_rounded,
                            size: 32,
                            color: Colors.deepPurpleAccent,
                            title: l10n.settingsCredit,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AppNormalDialog(
                                      title: l10n.settingsCredit);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Gap(8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: ListTile(
                          leading: Icon(
                            Icons.phone_android,
                            color: Colors.black,
                          ),
                          title: Text(
                            l10n.settingsDeviceInfo,
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            state.model,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: ListTile(
                          leading: Icon(
                            Platform.isAndroid ? Icons.android : Icons.apple,
                            color:
                                Platform.isAndroid ? Colors.green : Colors.red,
                          ),
                          title: Text(
                            Platform.isAndroid
                                ? l10n.settingsAndroidSdk
                                : l10n.settingsIosVersion,
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            state.sdk,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: ListTile(
                          leading: Icon(Icons.settings, color: Colors.grey),
                          title: Text(
                            l10n.settingsAppVersion,
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Text(
                            state.version,
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                      subscriptionState.when(
                        data: (isSubscribed) {
                          return !isSubscribed
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 16,
                                  ),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      tileColor: Color(0xFFFFFDD0),
                                      leading: Icon(
                                        FontAwesomeIcons.crown,
                                        color: Colors.yellow,
                                        size: 32,
                                      ),
                                      trailing: Icon(
                                        FontAwesomeIcons.crown,
                                        color: Colors.yellow,
                                        size: 32,
                                      ),
                                      subtitleTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      title: Center(
                                        child: Text(
                                          //TODO 多言語化する
                                          // 'プレミアムメンバーシップになる',
                                          'Get a Premium MemberShip',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        context
                                            .pushNamed(RouterPath.paywallPage);
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox.shrink();
                        },
                        error: (_, __) {
                          return SizedBox.shrink();
                        },
                        loading: () {
                          return SizedBox.shrink();
                        },
                      ),
                      Gap(12),
                      Wrap(
                        children: [
                          AppSettingTile(
                            icon: Icons.power_settings_new,
                            size: 32,
                            color: Colors.red,
                            title: l10n.settingsLogoutButton,
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AppLogoutDialog(
                                    logout: () {
                                      ref
                                          .read(settingViewModelProvider()
                                              .notifier)
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
                                            openErrorSnackBar(
                                              context,
                                              l10n.logoutFailure,
                                              '',
                                            );
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.delete,
                            size: 36,
                            color: Colors.red,
                            title: l10n.settingsDeleteAccountButton,
                            onTap: () {
                              LaunchUrl()
                                  .open(
                                'https://forms.gle/B2cG3FEynh1tbfUdA',
                              )
                                  .then((value) {
                                if (!value) {
                                  openErrorSnackBar(
                                    context,
                                    l10n.accountDeletionFailure,
                                    '',
                                  );
                                }
                              });
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.restore,
                            size: 32,
                            color: Colors.black,
                            title: l10n.settingRestore,
                            onTap: () {
                              ref
                                  .read(settingViewModelProvider().notifier)
                                  .restore()
                                  .then(
                                (isRestore) {
                                  if (isRestore) {
                                    openSuccessSnackBar(
                                      context,
                                      l10n.settingRestoreSuccessTitle,
                                      l10n.settingRestoreSuccessSubtitle,
                                    );
                                  } else {
                                    openErrorSnackBar(
                                      context,
                                      l10n.settingRestoreFailureTitle,
                                      l10n.settingRestoreFailureSubtitle,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              AdmobBanner(), // 最下部に配置
            ],
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
