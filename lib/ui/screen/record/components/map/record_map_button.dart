import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/ui/component/dialog/app_map_stats_share_dialog.dart';

/// 記録タブ地図上：方位リセット・統計シェアの FAB 列
class RecordMapButton extends StatelessWidget {
  const RecordMapButton({
    required this.onResetBearing,
    required this.postsCount,
    required this.visitedPrefecturesCount,
    required this.visitedCountriesCount,
    super.key,
  });

  final VoidCallback onResetBearing;
  final int postsCount;
  final int visitedPrefecturesCount;
  final int visitedCountriesCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fabBg = isDark ? Colors.black : Colors.white;
    const fabFg = AppTheme.primaryBlue;
    final fabBorder = isDark ? Colors.white54 : Colors.grey.shade300;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: fabBg,
                ),
                child: FloatingActionButton(
                  heroTag: 'recordMapCompass',
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: fabBorder),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  foregroundColor: fabBg,
                  backgroundColor: fabBg,
                  focusColor: fabBg,
                  splashColor: fabBg,
                  hoverColor: fabBg,
                  elevation: 10,
                  onPressed: onResetBearing,
                  child: const Icon(
                    CupertinoIcons.compass,
                    color: fabFg,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Theme(
                data: Theme.of(context).copyWith(
                  highlightColor: fabBg,
                ),
                child: FloatingActionButton(
                  heroTag: 'recordMapShareStats',
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: fabBorder),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  foregroundColor: fabBg,
                  backgroundColor: fabBg,
                  focusColor: fabBg,
                  splashColor: fabBg,
                  hoverColor: fabBg,
                  elevation: 10,
                  onPressed: () {
                    showGeneralDialog<void>(
                      context: context,
                      pageBuilder: (_, __, ___) {
                        return AppMapStatsShareDialog(
                          postsCount: postsCount,
                          visitedPrefecturesCount: visitedPrefecturesCount,
                          visitedCountriesCount: visitedCountriesCount,
                        );
                      },
                    );
                  },
                  child: const Icon(
                    Icons.ios_share,
                    color: fabFg,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
