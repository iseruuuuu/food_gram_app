import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/model/weekly_summary.dart';
import 'package:food_gram_app/core/theme/memory_album_theme.dart';
import 'package:food_gram_app/core/utils/helpers/share_helper.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/core/weekly_summary/weekly_summary_provider.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/screen/weekly_summary/components/weekly_summary_content.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WeeklySummaryScreen extends HookConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final summaryAsync = ref.watch(weeklySummaryProvider);
    final sharing = useState(false);
    final shareBoundaryKey = useMemoized(GlobalKey.new);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF1A1A1A) : MemoryAlbumTheme.creamBackground;

    useEffect(
      () {
        final summary = summaryAsync.asData?.value;
        if (summaryAsync.hasValue && summary == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.pop();
            }
          });
        }
        return null;
      },
      [summaryAsync],
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          summaryAsync.maybeWhen(
            data: (summary) {
              if (summary == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: sharing.value
                    ? null
                    : () => _share(
                          context: context,
                          ref: ref,
                          summary: summary,
                          boundaryKey: shareBoundaryKey,
                          loading: sharing,
                        ),
                icon: Icon(
                  CupertinoIcons.share,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Stack(
        children: [
          summaryAsync.when(
            data: (summary) {
              if (summary == null) {
                return const SizedBox.shrink();
              }
              return SingleChildScrollView(
                child: RepaintBoundary(
                  key: shareBoundaryKey,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: background),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: WeeklySummaryContent(summary: summary),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(t.close),
              ),
            ),
          ),
          AppProcessLoading(
            loading: sharing.value,
            status: t.weeklySummary.shareLoading,
          ),
        ],
      ),
    );
  }

  Future<void> _share({
    required BuildContext context,
    required WidgetRef ref,
    required WeeklySummary summary,
    required GlobalKey boundaryKey,
    required ValueNotifier<bool> loading,
  }) async {
    final t = Translations.of(context);
    final bestPost = summary.bestPost;
    final precacheImageUrl =
        bestPost == null ? null : postImageUrl(ref, bestPost);
    await ShareHelpers().captureBoundaryAndShare(
      context: context,
      boundaryKey: boundaryKey,
      loading: loading,
      hasText: true,
      shareText: t.weeklySummary.shareText,
      errorMessage: t.weeklySummary.shareError,
      precacheImageUrl: precacheImageUrl,
    );
  }
}
