import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/analytics/analytics_event.dart';
import 'package:food_gram_app/core/analytics/firebase_analytics_service.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/app_elevated_button.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/friend/friend_add_view_model.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FriendAddScreen extends HookConsumerWidget {
  const FriendAddScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        ref
            .read(firebaseAnalyticsServiceProvider)
            .logEventUnawaited(name: AnalyticsEvent.friendAddOpen);
        return null;
      },
      const [],
    );
    final t = Translations.of(context);
    final state = ref.watch(friendAddViewModelProvider());
    final loading = ref.watch(loadingProvider);
    final codeController = useTextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;

    Future<void> copyMyCode() async {
      final code = state.myFriendCode;
      if (code.isEmpty) {
        SnackBarHelper().openErrorSnackBar(context, t.friend.codeMissing, '');
        return;
      }
      await Clipboard.setData(ClipboardData(text: code));
      if (!context.mounted) {
        return;
      }
      SnackBarHelper().openSuccessSnackBar(context, t.friend.copied, '');
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : scheme.surface,
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : scheme.surface,
          title: Text(
            t.friend.addTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          elevation: 0.5,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: 32,
              color: onSurface,
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.friend.yourCode,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      state.isLoadingCode
                          ? '...'
                          : (state.myFriendCode.isEmpty
                              ? '-'
                              : state.myFriendCode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: onSurface,
                      ),
                    ),
                  ),
                  const Gap(16),
                  Center(
                    child: AppElevatedButton(
                      onPressed: copyMyCode,
                      title: t.friend.copy,
                      horizontalInset: 80,
                    ),
                  ),
                  const Gap(32),
                  Divider(color: scheme.outlineVariant),
                  const Gap(32),
                  Text(
                    t.friend.inputLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const Gap(12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: TextField(
                      controller: codeController,
                      keyboardType: TextInputType.visiblePassword,
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      enableSuggestions: false,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9]'),
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          return newValue.copyWith(
                            text: newValue.text.toUpperCase(),
                          );
                        }),
                      ],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        hintText: t.friend.inputHint,
                        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ),
                  const Gap(24),
                  Center(
                    child: AppElevatedButton(
                      onPressed: () async {
                        final added = await ref
                            .read(friendAddViewModelProvider().notifier)
                            .addFriend(context, codeController.text);
                        if (added && context.mounted) {
                          codeController.clear();
                        }
                      },
                      title: t.friend.addButton,
                      backgroundColor: AppTheme.primaryBlue,
                      horizontalInset: 40,
                    ),
                  ),
                ],
              ),
            ),
            AppProcessLoading(
              loading: loading,
              status: 'Loading...',
            ),
          ],
        ),
      ),
    );
  }
}
