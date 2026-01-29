import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/config/constants/url.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';
import 'package:food_gram_app/core/theme/style/setting_style.dart';
import 'package:food_gram_app/core/utils/helpers/dialog_helper.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/helpers/url_launch_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/i18n/strings.g.dart';
import 'package:food_gram_app/router/router.dart';
import 'package:food_gram_app/ui/component/app_premium_membership_card.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/setting/components/setting_tile.dart';
import 'package:food_gram_app/ui/screen/setting/setting_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loadingProvider);
    final state = ref.watch(settingViewModelProvider());
    final isSubscribeAsync = ref.watch(isSubscribeProvider);
    final t = Translations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          elevation: 0,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Gap(12),
                      Wrap(
                        children: [
                          SettingTile(
                            icon: FontAwesomeIcons.twitter,
                            title: t.settingDeveloper,
                            onTap: () => LaunchUrlHelper().openSNSUrl(URL.sns),
                          ),
                          SettingTile(
                            icon: FontAwesomeIcons.github,
                            title: t.settingGithub,
                            onTap: () =>
                                LaunchUrlHelper().openSNSUrl(URL.github),
                          ),
                          SettingTile(
                            icon: Icons.verified,
                            title: t.settingLicense,
                            onTap: () => context.pushNamed(RouterPath.license),
                          ),
                          SettingTile(
                            icon: Icons.share,
                            title: t.settingShareApp,
                            onTap: () {
                              final url = Platform.isIOS
                                  ? URL.appleStore
                                  : URL.googleStore;
                              ShareHelpers().shareNormal(url);
                            },
                          ),
                          SettingTile(
                            icon: Icons.rate_review_outlined,
                            title: t.settingReview,
                            onTap: () => ref
                                .read(settingViewModelProvider().notifier)
                                .review(),
                          ),
                          SettingTile(
                            icon: Icons.system_update,
                            title: t.settingCheckVersion,
                            onTap: () => ref
                                .read(settingViewModelProvider().notifier)
                                .checkNewVersion(context),
                          ),
                          SettingTile(
                            icon: Icons.help_outline,
                            title: t.settingFaq,
                            onTap: () =>
                                LaunchUrlHelper().open(URL.faq(context)),
                          ),
                          SettingTile(
                            icon: Icons.security,
                            title: t.settingPrivacyPolicy,
                            onTap: () => LaunchUrlHelper()
                                .open(URL.privacyPolicy(context)),
                          ),
                          SettingTile(
                            icon: Icons.assignment,
                            title: t.settingTermsOfUse,
                            onTap: () =>
                                LaunchUrlHelper().open(URL.termsOfUse(context)),
                          ),
                          SettingTile(
                            icon: Icons.chat,
                            title: t.settingContact,
                            onTap: () => LaunchUrlHelper().open(URL.contact),
                          ),
                          SettingTile(
                            icon: Icons.school,
                            title: t.settingTutorial,
                            onTap: () =>
                                context.pushNamed(RouterPath.settingTutorial),
                          ),
                          SettingTile(
                            icon: CupertinoIcons.cube_box_fill,
                            title: t.settingQuestion,
                            onTap: () {
                              LaunchUrlHelper().open(URL.question);
                            },
                          ),
                        ],
                      ),
                      const Gap(8),
                      isSubscribeAsync.when(
                        data: (isSubscribed) => isSubscribed
                            ? const SizedBox.shrink()
                            : const AppPremiumMembershipCard(),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const AppPremiumMembershipCard(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0168B7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const Gap(8),
                            Text(
                              t.settingAccountManagement,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(16),
                      Wrap(
                        children: [
                          SettingTile(
                            icon: Icons.power_settings_new,
                            title: t.settingLogoutButton,
                            onTap: () {
                              DialogHelper().openLogoutDialog(
                                title: t.dialogLogoutTitle,
                                text: '${t.dialogLogoutDescription1}\n'
                                    '${t.dialogLogoutDescription2}',
                                onTap: () {
                                  context.pop();
                                  ref
                                      .read(settingViewModelProvider().notifier)
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
                                          t.logoutFailure,
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
                          SettingTile(
                            icon: Icons.delete,
                            title: t.settingDeleteAccountButton,
                            onTap: () {
                              LaunchUrlHelper()
                                  .open('https://forms.gle/B2cG3FEynh1tbfUdA')
                                  .then((value) {
                                if (!value) {
                                  SnackBarHelper().openErrorSnackBar(
                                    context,
                                    t.accountDeletionFailure,
                                    '',
                                  );
                                }
                              });
                            },
                          ),
                          SettingTile(
                            icon: Icons.restore,
                            title: t.settingRestore,
                            onTap: () {
                              ref
                                  .read(settingViewModelProvider().notifier)
                                  .restore()
                                  .then(
                                (isRestore) {
                                  if (isRestore) {
                                    SnackBarHelper().openSuccessSnackBar(
                                      context,
                                      t.settingRestoreSuccessTitle,
                                      t.settingRestoreSuccessSubtitle,
                                    );
                                  } else {
                                    SnackBarHelper().openErrorSnackBar(
                                      context,
                                      t.settingRestoreFailureTitle,
                                      t.settingRestoreFailureSubtitle,
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.settings,
                                color: Colors.grey,
                              ),
                              title: Text(
                                t.settingAppVersion,
                                style: SettingStyle.appVersion(),
                              ),
                              trailing: Text(
                                state.version,
                                style: SettingStyle.version(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const AdmobBanner(id: 'setting'),
            ],
          ),
          AppProcessLoading(
            loading: loading,
            status: 'Loading...',
          ),
        ],
      ),
    );
  }
}
