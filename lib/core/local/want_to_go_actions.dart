import 'package:flutter/material.dart';
import 'package:food_gram_app/core/local/providers/want_to_go_notifier.dart';
import 'package:food_gram_app/core/model/restaurant.dart';
import 'package:food_gram_app/core/model/want_to_go_item.dart';
import 'package:food_gram_app/core/utils/helpers/snack_bar_helper.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

bool isWantToGoListed(WidgetRef ref, Restaurant restaurant) {
  final items =
      ref.watch(wantToGoNotifierProvider).valueOrNull ?? const <WantToGoItem>[];
  return items.any((e) => e.matchesRestaurant(restaurant));
}

Future<void> toggleWantToGoWithFeedback({
  required BuildContext context,
  required WidgetRef ref,
  required Restaurant restaurant,
}) async {
  final t = Translations.of(context);
  final added =
      await ref.read(wantToGoNotifierProvider.notifier).toggle(restaurant);
  if (!context.mounted) {
    return;
  }
  SnackBarHelper().openSuccessSnackBar(
    context,
    added ? t.wantToGo.added : t.wantToGo.removed,
    '',
  );
}
