import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/purchase/providers/subscription_provider.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_app_bar.dart';
import 'package:food_gram_app/ui/component/app_loading.dart';
import 'package:food_gram_app/ui/component/app_setting_tile.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snow_fall_animation/snow_fall_animation.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final state = ref.watch(settingViewModelProvider());
    final l10n = L10n.of(context);
    final subscriptionState = ref.watch(subscriptionProvider);
    final isSnowing = useState(false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(),
      body: Stack(
        children: [
          if (isSnowing.value)
            const SnowFallAnimation(
              config: SnowfallConfig(
                numberOfSnowflakes: 300,
                enableRandomOpacity: false,
                enableSnowDrift: false,
                holdSnowAtBottom: false,
              ),
            ),
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
                              LaunchUrlHelper().openSNSUrl(URL.sns);
                            },
                          ),
                          AppSettingTile(
                            icon: FontAwesomeIcons.github,
                            title: l10n.settingsGithub,
                            onTap: () {
                              LaunchUrlHelper().openSNSUrl(URL.github);
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
                                ShareHelpers().shareNormal(URL.appleStore);
                              } else {
                                ShareHelpers().shareNormal(URL.googleStore);
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
                              LaunchUrlHelper().open(URL.faq);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.security,
                            color: Colors.indigoAccent,
                            title: l10n.settingsPrivacyPolicy,
                            onTap: () {
                              LaunchUrlHelper().open(URL.privacyPolicy);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.assignment,
                            color: Colors.deepPurpleAccent,
                            title: l10n.settingsTermsOfUse,
                            onTap: () {
                              LaunchUrlHelper().open(URL.termsOfUse);
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.chat,
                            size: 32,
                            color: Colors.lightBlue,
                            title: l10n.settingsContact,
                            onTap: () {
                              LaunchUrlHelper().open(URL.contact);
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
                          trailing: GestureDetector(
                            onTap: () => isSnowing.value = !isSnowing.value,
                            child: Text(
                              state.sdk,
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
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
                                  padding: EdgeInsets.symmetric(horizontal: 12),
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
                                          'Get a Premium MemberShip',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        context
                                            .pushNamed(RouterPath.paywallPage)
                                            .then((_) {
                                          ref.invalidate(subscriptionProvider);
                                        });
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
                              DialogHelper().openLogoutDialog(
                                title: l10n.dialogLogoutTitle,
                                text: '${l10n.dialogLogoutDescription1}\n'
                                    '${l10n.dialogLogoutDescription2}',
                                onTap: () {
                                  context.pop();
                                  ref
                                      .read(
                                        settingViewModelProvider().notifier,
                                      )
                                      .signOut()
                                      .then(
                                    (value) {
                                      if (value) {
                                        context.pushReplacementNamed(
                                          RouterPath.authentication,
                                        );
                                      } else {
                                        SnackBarHelper().openErrorSnackBar(
                                          context,
                                          l10n.logoutFailure,
                                          '',
                                        );
                                      }
                                    },
                                  );
                                },
                                context: context,
                              );
                            },
                          ),
                          AppSettingTile(
                            icon: Icons.delete,
                            size: 36,
                            color: Colors.red,
                            title: l10n.settingsDeleteAccountButton,
                            onTap: () {
                              LaunchUrlHelper()
                                  .open(
                                'https://forms.gle/B2cG3FEynh1tbfUdA',
                              )
                                  .then((value) {
                                if (!value) {
                                  SnackBarHelper().openErrorSnackBar(
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
                                    SnackBarHelper().openSuccessSnackBar(
                                      context,
                                      l10n.settingRestoreSuccessTitle,
                                      l10n.settingRestoreSuccessSubtitle,
                                    );
                                  } else {
                                    SnackBarHelper().openErrorSnackBar(
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
              AdmobBanner(),
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
