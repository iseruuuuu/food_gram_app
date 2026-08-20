import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/user/providers/is_subscribe_provider.dart';

/// 広告リクエストしてよいのは、非サブスクだと確定したときだけ。
///
/// ローディング・エラー・未確定は出さない。サブスク中に AdMob SDK を
/// 呼ばない（デバッグのテスト広告も同様）。
bool canRequestAds(AsyncValue<bool> subscription) {
  return subscription.maybeWhen(
    data: (isSubscribed) => !isSubscribed,
    orElse: () => false,
  );
}

bool canRequestAdsFrom(Ref ref) {
  return canRequestAds(ref.read(isSubscribeProvider));
}
