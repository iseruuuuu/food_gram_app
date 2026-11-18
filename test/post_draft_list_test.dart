import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/post_draft.dart';

void main() {
  test('a sixth new draft needs a subscription on the free plan', () {
    expect(
      PostDraftList.needsSubscriptionToAdd(savedCount: 5, isPremium: false),
      isTrue,
    );
    expect(
      PostDraftList.needsSubscriptionToAdd(savedCount: 6, isPremium: false),
      isTrue,
    );
    expect(
      PostDraftList.needsSubscriptionToAdd(savedCount: 4, isPremium: false),
      isFalse,
    );
    expect(
      PostDraftList.needsSubscriptionToAdd(savedCount: 5, isPremium: true),
      isFalse,
    );
  });
}
