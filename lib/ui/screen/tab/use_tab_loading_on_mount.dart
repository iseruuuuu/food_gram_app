import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

/// タブ画面がマウントされるたびにローディングを表示する。
/// データがキャッシュ済みでも、最低表示時間はローディングを維持する。
bool useTabLoadingOnMount({
  required bool dataReady,
  Duration minDuration = const Duration(milliseconds: 800),
}) {
  final showLoading = useState(true);

  useEffect(
    () {
      if (!dataReady) {
        showLoading.value = true;
        return null;
      }
      final timer = Timer(minDuration, () {
        showLoading.value = false;
      });
      return timer.cancel;
    },
    [dataReady],
  );

  return showLoading.value;
}
