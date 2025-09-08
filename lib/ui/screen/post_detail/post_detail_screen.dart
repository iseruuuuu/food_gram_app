import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:food_gram_app/core/admob/services/admob_banner.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/model/users.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:food_gram_app/core/utils/provider/loading.dart';
import 'package:food_gram_app/env.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';
import 'package:food_gram_app/ui/component/app_heart.dart';
import 'package:food_gram_app/ui/component/common/app_loading.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_master_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_my_info_modal_sheet.dart';
import 'package:food_gram_app/ui/component/modal_sheet/app_detail_other_info_modal_sheet.dart';
import 'package:food_gram_app/ui/screen/post_detail/post_detail_view_model.dart';
import 'package:food_gram_app/ui/screen/post_detail/widgets/post_detail_list_item.dart';
import 'package:food_gram_app/ui/screen/post_detail/widgets/post_detail_user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostDetailScreen extends HookConsumerWidget {
  const PostDetailScreen({
    required this.posts,
    required this.users,
    super.key,
  });

  final Posts posts;
  final Users users;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(
      () {
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeStoreState(posts.id);
        ref
            .read(postDetailViewModelProvider().notifier)
            .initializeHeartState(posts.id, posts.heart);
        return;
      },
      [posts.id],
    );

    final l10n = L10n.of(context);
    final menuLoading = useState(false);
    final loading = ref.watch(loadingProvider);
    final currentUser = ref.watch(currentUserProvider);
    final detailState = ref.watch(postDetailViewModelProvider());
    final listState = ref.watch(postDetailListProvider(posts));

    return PopScope(
      canPop: !loading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: !loading,
          surfaceTintColor: Colors.transparent,
          leading: loading || menuLoading.value
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () => context.pop(),
                  child: const Icon(
                    Icons.close,
                    size: 30,
                  ),
                ),
          actions: [
            if (!loading && !menuLoading.value)
              IconButton(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      if (currentUser == Env.masterAccount) {
                        return AppDetailMasterModalSheet(
                          posts: posts,
                          users: users,
                          delete: (posts) async {
                            await ref
                                .read(postDetailViewModelProvider().notifier)
                                .delete(posts);
                          },
                        );
                      }
                      if (users.userId != currentUser) {
                        return AppDetailOtherInfoModalSheet(
                          users: users,
                          posts: posts,
                          loading: menuLoading,
                          block: (userId) async {
                            return ref
                                .read(postDetailViewModelProvider().notifier)
                                .block(userId);
                          },
                        );
                      } else {
                        return AppDetailMyInfoModalSheet(
                          users: users,
                          posts: posts,
                          loading: menuLoading,
                          delete: (posts) async {
                            await ref
                                .read(postDetailViewModelProvider().notifier)
                                .delete(posts);
                          },
                          setUser: (posts) {
                            // リストの更新処理は必要に応じて実装
                          },
                        );
                      }
                    },
                  );
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              listState.when(
                loading: () => const AppProcessLoading(
                  loading: true,
                  status: 'Loading...',
                ),
                error: (error, stack) => const Center(
                  child: Text('エラーが発生しました'),
                ),
                data: (posts) => ListView.builder(
                  itemCount: posts.length + 1, // +1 for AdMob banner
                  itemBuilder: (context, index) {
                    if (index == posts.length) {
                      return const AdmobBanner(id: 'detail');
                    }

                    final post = posts[index];
                    return FutureBuilder<Users>(
                      future:
                          ref.read(postDetailUserProvider(post.userId).future),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          return PostDetailListItem(
                            posts: post,
                            users: user,
                            menuLoading: menuLoading,
                            onHeartLimitReached: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.heartLimitMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const SizedBox(
                            height: 100,
                            child: Center(
                              child: Text('エラーが発生しました'),
                            ),
                          );
                        } else {
                          return const SizedBox(
                            height: 100,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              AppHeart(isHeart: detailState.isAppearHeart),
              AppProcessLoading(
                loading: menuLoading.value || loading,
                status: 'Loading...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
