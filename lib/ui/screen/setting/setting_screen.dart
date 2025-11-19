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
import 'package:food_gram_app/gen/l10n/l10n.dart';
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
    final l10n = L10n.of(context);
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
                            title: l10n.settingDeveloper,
                            onTap: () => LaunchUrlHelper().openSNSUrl(URL.sns),
                          ),
                          SettingTile(
                            icon: FontAwesomeIcons.github,
                            title: l10n.settingGithub,
                            onTap: () =>
                                LaunchUrlHelper().openSNSUrl(URL.github),
                          ),
                          SettingTile(
                            icon: Icons.verified,
                            title: l10n.settingLicense,
                            onTap: () => context.pushNamed(RouterPath.license),
                          ),
                          SettingTile(
                            icon: Icons.share,
                            title: l10n.settingShareApp,
                            onTap: () {
                              final url = Platform.isIOS
                                  ? URL.appleStore
                                  : URL.googleStore;
                              ShareHelpers().shareNormal(url);
                            },
                          ),
                          SettingTile(
                            icon: Icons.rate_review_outlined,
                            title: l10n.settingReview,
                            onTap: () => ref
                                .read(settingViewModelProvider().notifier)
                                .review(),
                          ),
                          SettingTile(
                            icon: Icons.system_update,
                            title: l10n.settingCheckVersion,
                            onTap: () => ref
                                .read(settingViewModelProvider().notifier)
                                .checkNewVersion(context),
                          ),
                          SettingTile(
                            icon: Icons.help_outline,
                            title: l10n.settingFaq,
                            onTap: () => LaunchUrlHelper().open(URL.faq),
                          ),
                          SettingTile(
                            icon: Icons.security,
                            title: l10n.settingPrivacyPolicy,
                            onTap: () =>
                                LaunchUrlHelper().open(URL.privacyPolicy),
                          ),
                          SettingTile(
                            icon: Icons.assignment,
                            title: l10n.settingTermsOfUse,
                            onTap: () => LaunchUrlHelper().open(URL.termsOfUse),
                          ),
                          SettingTile(
                            icon: Icons.chat,
                            title: l10n.settingContact,
                            onTap: () => LaunchUrlHelper().open(URL.contact),
                          ),
                          SettingTile(
                            icon: Icons.school,
                            title: l10n.settingTutorial,
                            onTap: () =>
                                context.pushNamed(RouterPath.settingTutorial),
                          ),
                          SettingTile(
                            icon: CupertinoIcons.cube_box_fill,
                            title: l10n.settingQuestion,
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
                              l10n.settingAccountManagement,
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
                            title: l10n.settingLogoutButton,
                            onTap: () {
                              DialogHelper().openLogoutDialog(
                                title: l10n.dialogLogoutTitle,
                                text: '${l10n.dialogLogoutDescription1}\n'
                                    '${l10n.dialogLogoutDescription2}',
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
                          SettingTile(
                            icon: Icons.delete,
                            title: l10n.settingDeleteAccountButton,
                            onTap: () {
                              LaunchUrlHelper()
                                  .open('https://forms.gle/B2cG3FEynh1tbfUdA')
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
                          SettingTile(
                            icon: Icons.restore,
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
                                l10n.settingAppVersion,
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
