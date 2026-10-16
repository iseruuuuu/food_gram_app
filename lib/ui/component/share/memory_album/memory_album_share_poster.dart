import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_gram_app/core/model/memory_album.dart';
import 'package:food_gram_app/core/model/posts.dart';
import 'package:food_gram_app/core/supabase/post/analyzer/record_food_traits_analyzer.dart';
import 'package:food_gram_app/core/theme/app_theme.dart';
import 'package:food_gram_app/core/utils/memory_album_utils.dart';
import 'package:food_gram_app/gen/assets.gen.dart';
import 'package:food_gram_app/gen/strings.g.dart';
import 'package:food_gram_app/ui/component/share/component/post_share_image.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// 思い出アルバムのSNSシェア用エディトリアルポスター（9:16 縦長）。
///
/// 写真が1〜9枚のどのパターンでも、フードマガジンやスクラップブックのような
/// 完成された1枚のポスターとして自動レイアウトされる。
class MemoryAlbumSharePoster extends StatelessWidget {
  const MemoryAlbumSharePoster({
    required this.album,
    required this.posts,
    required this.imageUrls,
    super.key,
  });

  final MemoryAlbum album;
  final List<Posts> posts;

  /// 表示する写真URL一覧（最大9枚まで先頭から使用）
  final List<String> imageUrls;

  /// ベース解像度（360×640 = 9:16）。
  /// キャプチャ時に pixelRatio: 4 を掛けることで 1440×2560px の超高画質出力となる。
  static const Size size = Size(360, 640);

  static const Color _bgCream = Color(0xFFFBF8F3);
  static const Color _inkPrimary = Color(0xFF29231F);
  static const Color _inkSecondary = Color(0xFF7A7067);
  static const Color _borderLine = Color(0xFFE8DFD5);

  static String get _serifFamily => Platform.isIOS ? 'Georgia' : 'serif';

  /// 最大9枚に制限した画像URLリスト
  List<String> get effectiveImageUrls {
    final nonEmpty = imageUrls.where((u) => u.trim().isNotEmpty).toList();
    if (nonEmpty.length <= 9) {
      return nonEmpty;
    }
    return nonEmpty.sublist(0, 9);
  }

  /// 対象期間の表示文字列（例: October 2026 / Oct 2026 - Nov 2026）
  String periodLabel() {
    final range = postDateRange(posts);
    final start = range.start ?? album.createdAt;
    final end = range.end ?? album.createdAt;
    final startFmt = DateFormat('MMMM yyyy', 'en_US');
    if (start.year == end.year && start.month == end.month) {
      return startFmt.format(start);
    }
    final shortFmt = DateFormat('MMM yyyy', 'en_US');
    return '${shortFmt.format(start)} – ${shortFmt.format(end)}';
  }

  String shareMessage(Translations t) {
    final title = album.title.trim();
    final period = periodLabel();
    return '$title ($period)\n\n'
        '${t.share.inviteMessage}\n'
        '#FoodGram';
  }

  @override
  Widget build(BuildContext context) {
    final urls = effectiveImageUrls;
    final mealsCount = posts.length;
    final placesCount = recordUniqueRestaurantsCount(posts);
    final period = periodLabel();
    final albumTitle = album.title.trim();
    final description = album.description.trim();
    final firstPost = posts.isNotEmpty ? posts.first : null;
    final count = urls.length.clamp(1, 9);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: _bgCream,
        ),
        child: Stack(
          children: [
            // 上部の淡いブランドオレンジグラデーション装飾
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 140,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.orangeLight.withValues(alpha: 0.55),
                      _bgCream.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // 外周の極細エディトリアルフレーム線
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _borderLine,
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                children: [
                  _EditorialHeader(
                    periodLabel: period,
                    albumTitle: albumTitle,
                    description: description,
                    photoCount: count,
                  ),
                  const Gap(12),
                  Expanded(
                    child: _PhotoCollageStage(
                      imageUrls: urls,
                      firstPost: firstPost,
                    ),
                  ),
                  const Gap(12),
                  _EditorialFooter(
                    mealsCount: mealsCount,
                    placesCount: placesCount,
                    photoCount: count,
                    firstPost: firstPost,
                    description: description,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader({
    required this.periodLabel,
    required this.albumTitle,
    required this.description,
    required this.photoCount,
  });

  final String periodLabel;
  final String albumTitle;
  final String description;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final isSingleCover = photoCount == 1;
    return Column(
      crossAxisAlignment:
          isSingleCover ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: isSingleCover
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 1,
              color: AppTheme.primaryOrange.withValues(alpha: 0.65),
            ),
            const Gap(6),
            Text(
              'MY FOOD MEMORIES',
              style: TextStyle(
                fontFamily: MemoryAlbumSharePoster._serifFamily,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: AppTheme.orangeDark,
              ),
            ),
            const Gap(6),
            Container(
              width: 16,
              height: 1,
              color: AppTheme.primaryOrange.withValues(alpha: 0.65),
            ),
          ],
        ),
        const Gap(4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            periodLabel,
            maxLines: 1,
            textAlign: isSingleCover ? TextAlign.left : TextAlign.center,
            style: TextStyle(
              fontFamily: MemoryAlbumSharePoster._serifFamily,
              fontSize: 25,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              height: 1.1,
              color: MemoryAlbumSharePoster._inkPrimary,
            ),
          ),
        ),
        if (albumTitle.isNotEmpty) ...[
          const Gap(5),
          Text(
            albumTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isSingleCover ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              height: 1.25,
              color: MemoryAlbumSharePoster._inkSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoCollageStage extends StatelessWidget {
  const _PhotoCollageStage({
    required this.imageUrls,
    this.firstPost,
  });

  final List<String> imageUrls;
  final Posts? firstPost;

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length;
    if (count <= 0) {
      return const SizedBox.shrink();
    }
    return switch (count) {
      1 => _Layout1Cover(
          imageUrl: imageUrls[0],
          post: firstPost,
        ),
      2 => _Layout2Scrapbook(imageUrls: imageUrls),
      3 => _Layout3Rhythm(imageUrls: imageUrls),
      4 => _Layout4Grid(imageUrls: imageUrls),
      5 => _Layout5Magazine(imageUrls: imageUrls),
      6 => _Layout6Grid(imageUrls: imageUrls),
      7 => _Layout7Featured(imageUrls: imageUrls),
      8 => _Layout8Grid(imageUrls: imageUrls),
      _ => _Layout9Magazine(imageUrls: imageUrls),
    };
  }
}

/// 1枚：雑誌の表紙のように大きく配置
class _Layout1Cover extends StatelessWidget {
  const _Layout1Cover({
    required this.imageUrl,
    this.post,
  });

  final String imageUrl;
  final Posts? post;

  @override
  Widget build(BuildContext context) {
    final restaurant = post?.restaurant.trim() ?? '';
    final foodName = post?.foodName.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _FramedPhoto(
            imageUrl: imageUrl,
            borderWidth: 5,
            radius: 6,
            overlayBottom: Padding(
              padding: const EdgeInsets.fromLTRB(14, 24, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Good food, Better days.',
                    style: TextStyle(
                      fontFamily: MemoryAlbumSharePoster._serifFamily,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: const [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (restaurant.isNotEmpty || foodName.isNotEmpty) ...[
          const Gap(8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppTheme.primaryOrange,
              ),
              const Gap(4),
              Expanded(
                child: Text(
                  restaurant.isNotEmpty ? restaurant : foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: MemoryAlbumSharePoster._inkSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 2枚：余白を活かしてわずかに角度をつけた上下2枚配置
class _Layout2Scrapbook extends StatelessWidget {
  const _Layout2Scrapbook({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          Expanded(
            child: Transform.rotate(
              angle: -0.028,
              child: _FramedPhoto(
                imageUrl: imageUrls[0],
                borderWidth: 5,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Transform.rotate(
              angle: 0.025,
              child: _FramedPhoto(
                imageUrl: imageUrls[1],
                borderWidth: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3枚：リズムのある非対称配置（上右・中左・下右）
class _Layout3Rhythm extends StatelessWidget {
  const _Layout3Rhythm({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final mainW = w * 0.64;
        final subW = w * 0.56;
        final itemH = h * 0.36;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              right: 4,
              width: mainW,
              height: itemH,
              child: Transform.rotate(
                angle: 0.022,
                child: _FramedPhoto(
                  imageUrl: imageUrls[0],
                  borderWidth: 4.5,
                ),
              ),
            ),
            Positioned(
              top: h * 0.31,
              left: 4,
              width: subW,
              height: itemH,
              child: Transform.rotate(
                angle: -0.03,
                child: _FramedPhoto(
                  imageUrl: imageUrls[1],
                  borderWidth: 4.5,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 8,
              width: subW,
              height: itemH,
              child: Transform.rotate(
                angle: 0.015,
                child: _FramedPhoto(
                  imageUrl: imageUrls[2],
                  borderWidth: 4.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 4枚：2×2の端正なグリッド＋エディトリアル余白
class _Layout4Grid extends StatelessWidget {
  const _Layout4Grid({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[0])),
              const Gap(8),
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[1])),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[2])),
              const Gap(8),
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[3])),
            ],
          ),
        ),
      ],
    );
  }
}

/// 5枚：メイン1枚＋サブ4枚のスクラップブック風レイアウト
class _Layout5Magazine extends StatelessWidget {
  const _Layout5Magazine({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Expanded(
                flex: 11,
                child: Column(
                  children: [
                    Expanded(
                      child: Transform.rotate(
                        angle: -0.018,
                        child: _FramedPhoto(imageUrl: imageUrls[0]),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Transform.rotate(
                        angle: 0.015,
                        child: _FramedPhoto(imageUrl: imageUrls[1]),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Expanded(
                flex: 10,
                child: Column(
                  children: [
                    const Gap(14),
                    Expanded(
                      child: Transform.rotate(
                        angle: 0.02,
                        child: _FramedPhoto(imageUrl: imageUrls[2]),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Transform.rotate(
                        angle: -0.015,
                        child: _FramedPhoto(imageUrl: imageUrls[3]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Transform.rotate(
              angle: -0.012,
              child: _FramedPhoto(imageUrl: imageUrls[4]),
            ),
          ),
        ),
      ],
    );
  }
}

/// 6枚：2列×3行のバランスのよいグリッド
class _Layout6Grid extends StatelessWidget {
  const _Layout6Grid({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 3; row++) ...[
          if (row > 0) const Gap(7),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _FramedPhoto(imageUrl: imageUrls[row * 2]),
                ),
                const Gap(7),
                Expanded(
                  child: _FramedPhoto(imageUrl: imageUrls[row * 2 + 1]),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 7枚：メイン1枚＋2列×3行のサブ6枚（または上部フィーチャー＋6枚グリッド）
class _Layout7Featured extends StatelessWidget {
  const _Layout7Featured({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(
                flex: 6,
                child: Transform.rotate(
                  angle: -0.016,
                  child: _FramedPhoto(imageUrl: imageUrls[0]),
                ),
              ),
              const Gap(7),
              Expanded(
                flex: 5,
                child: Transform.rotate(
                  angle: 0.018,
                  child: _FramedPhoto(imageUrl: imageUrls[1]),
                ),
              ),
            ],
          ),
        ),
        const Gap(7),
        Expanded(
          flex: 4,
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Transform.rotate(
                  angle: 0.014,
                  child: _FramedPhoto(imageUrl: imageUrls[2]),
                ),
              ),
              const Gap(7),
              Expanded(
                flex: 6,
                child: Transform.rotate(
                  angle: -0.015,
                  child: _FramedPhoto(imageUrl: imageUrls[3]),
                ),
              ),
            ],
          ),
        ),
        const Gap(7),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[4])),
              const Gap(6),
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[5])),
              const Gap(6),
              Expanded(child: _FramedPhoto(imageUrl: imageUrls[6])),
            ],
          ),
        ),
      ],
    );
  }
}

/// 8枚：2列×4行の整然としたグリッド
class _Layout8Grid extends StatelessWidget {
  const _Layout8Grid({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 4; row++) ...[
          if (row > 0) const Gap(6),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _FramedPhoto(
                    imageUrl: imageUrls[row * 2],
                    borderWidth: 3,
                  ),
                ),
                const Gap(6),
                Expanded(
                  child: _FramedPhoto(
                    imageUrl: imageUrls[row * 2 + 1],
                    borderWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 9枚：3×3のグリッドでフードマガジンのように美しくまとめる
class _Layout9Magazine extends StatelessWidget {
  const _Layout9Magazine({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < 3; row++) ...[
          if (row > 0) const Gap(6),
          Expanded(
            child: Row(
              children: [
                for (var col = 0; col < 3; col++) ...[
                  if (col > 0) const Gap(6),
                  Expanded(
                    child: _FramedPhoto(
                      imageUrl: imageUrls[row * 3 + col],
                      borderWidth: 3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 白フチと淡いドロップシャドウを持つ写真フレーム
class _FramedPhoto extends StatelessWidget {
  const _FramedPhoto({
    required this.imageUrl,
    this.borderWidth = 3.5,
    this.radius = 4,
    this.overlayBottom,
  });

  final String imageUrl;
  final double borderWidth;
  final double radius;
  final Widget? overlayBottom;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF29231F).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((radius - 1).clamp(1, 10)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PostShareImage(imageUrl: imageUrl),
              if (overlayBottom != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                    child: overlayBottom,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// フッター：実際の投稿数・訪問店舗数＋FoodGramブランド表記
class _EditorialFooter extends StatelessWidget {
  const _EditorialFooter({
    required this.mealsCount,
    required this.placesCount,
    required this.photoCount,
    this.firstPost,
    this.description = '',
  });

  final int mealsCount;
  final int placesCount;
  final int photoCount;
  final Posts? firstPost;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (description.isNotEmpty) ...[
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MemoryAlbumSharePoster._serifFamily,
              fontStyle: FontStyle.italic,
              fontSize: 11,
              color: MemoryAlbumSharePoster._inkSecondary,
            ),
          ),
          const Gap(8),
        ] else ...[
          Text(
            'Good food, Good memories.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: MemoryAlbumSharePoster._serifFamily,
              fontStyle: FontStyle.italic,
              fontSize: 11.5,
              letterSpacing: 0.4,
              color: MemoryAlbumSharePoster._inkSecondary,
            ),
          ),
          const Gap(8),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatCounter(
              value: '$mealsCount',
              label: mealsCount == 1 ? 'MEAL' : 'MEALS',
            ),
            if (placesCount > 0) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                width: 1,
                height: 24,
                color: MemoryAlbumSharePoster._borderLine,
              ),
              _StatCounter(
                value: '$placesCount',
                label: placesCount == 1 ? 'PLACE' : 'PLACES',
              ),
            ],
          ],
        ),
        const Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Assets.image.appIcon.image(
                width: 15,
                height: 15,
                fit: BoxFit.cover,
              ),
            ),
            const Gap(5),
            Text(
              'FoodGram',
              style: TextStyle(
                fontFamily: MemoryAlbumSharePoster._serifFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: MemoryAlbumSharePoster._inkPrimary,
              ),
            ),
          ],
        ),
        const Gap(2),
        Text(
          'Every meal becomes a memory.',
          style: TextStyle(
            fontFamily: MemoryAlbumSharePoster._serifFamily,
            fontSize: 8.5,
            letterSpacing: 0.5,
            color: MemoryAlbumSharePoster._inkSecondary,
          ),
        ),
      ],
    );
  }
}

class _StatCounter extends StatelessWidget {
  const _StatCounter({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: MemoryAlbumSharePoster._serifFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            height: 1.05,
            color: AppTheme.orangeDark,
          ),
        ),
        const Gap(2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: MemoryAlbumSharePoster._inkSecondary,
          ),
        ),
      ],
    );
  }
}

/// 複数枚シェア（カルーセル投稿）の2枚目以降に使う、表紙と統一されたエディトリアル写真カード（9:16）。
///
/// 投稿のテキスト詳細（料理名・店名・評価・コメント等）は入れず、
/// 最大2枚の料理写真をスクラップブック風に美しく見せる。
class MemoryAlbumShareSlideCard extends StatelessWidget {
  const MemoryAlbumShareSlideCard({
    required this.albumTitle,
    required this.imageUrls,
    required this.slideIndex,
    required this.totalSlides,
    super.key,
  });

  final String albumTitle;

  /// このスライドに配置する写真URL（1〜2枚）
  final List<String> imageUrls;

  /// 1始まりのスライド番号（例: 1 / 3）
  final int slideIndex;
  final int totalSlides;

  static const Size size = MemoryAlbumSharePoster.size;

  @override
  Widget build(BuildContext context) {
    final urls = imageUrls.where((u) => u.trim().isNotEmpty).take(2).toList();
    final indexLabel =
        '${slideIndex.toString().padLeft(2, '0')} / ${totalSlides.toString().padLeft(2, '0')}';

    return SizedBox(
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: MemoryAlbumSharePoster._bgCream,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.orangeLight.withValues(alpha: 0.48),
                      MemoryAlbumSharePoster._bgCream.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: MemoryAlbumSharePoster._borderLine,
                      width: 0.8,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        indexLabel,
                        style: TextStyle(
                          fontFamily: MemoryAlbumSharePoster._serifFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: AppTheme.orangeDark,
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          albumTitle.trim().isEmpty
                              ? 'MY FOOD MEMORIES'
                              : albumTitle.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: MemoryAlbumSharePoster._inkSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(14),
                  Expanded(
                    child: urls.length >= 2
                        ? _Layout2Scrapbook(imageUrls: urls)
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 28,
                            ),
                            child: _FramedPhoto(
                              imageUrl: urls.isNotEmpty ? urls.first : '',
                              borderWidth: 5,
                              radius: 6,
                            ),
                          ),
                  ),
                  const Gap(14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Assets.image.appIcon.image(
                          width: 15,
                          height: 15,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const Gap(5),
                      Text(
                        'FoodGram',
                        style: TextStyle(
                          fontFamily: MemoryAlbumSharePoster._serifFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: MemoryAlbumSharePoster._inkPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Gap(2),
                  Text(
                    'Every meal becomes a memory.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: MemoryAlbumSharePoster._serifFamily,
                      fontSize: 8.5,
                      letterSpacing: 0.5,
                      color: MemoryAlbumSharePoster._inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
