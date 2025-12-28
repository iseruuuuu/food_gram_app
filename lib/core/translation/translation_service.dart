import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// ML Kit のオンデバイス翻訳を扱うサービス。
final translationServiceProvider =
    Provider<TranslationService>((ref) => TranslationService());

class TranslationService {
  TranslationService({
    LanguageIdentifier? languageIdentifier,
    OnDeviceTranslatorModelManager? modelManager,
  })  : _identifier =
            languageIdentifier ?? LanguageIdentifier(confidenceThreshold: 0.5),
        _modelManager = modelManager ?? OnDeviceTranslatorModelManager();

  final LanguageIdentifier _identifier;
  final OnDeviceTranslatorModelManager _modelManager;

  /// 超軽量のメモリキャッシュ。アプリ再起動で消える。
  final Map<String, String> _memoryCache = <String, String>{};

  /// 指定 BCP-47 言語コードのモデルが無ければダウンロードする（内部用）。
  /// 既に存在する場合は true を返す。
  Future<bool> _downloadModelIfNeeded(String bcp47) async {
    final code = _normalizeBcp47(bcp47);
    final downloaded = await _modelManager.isModelDownloaded(code);
    if (downloaded) {
      return true;
    }
    return _modelManager.downloadModel(code);
  }

  /// 必要に応じて [text] を [targetLocale] の言語へ翻訳する。
  /// - 空文字は原文を返す
  /// - 言語判定で同一言語なら原文を返す
  /// - モデルが無ければ自動ダウンロードしてから翻訳
  Future<String> translateIfNeeded({
    required String text,
    required Locale targetLocale,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return text;
    }

    // 言語を推定
    final detected = await _safeIdentifyLanguage(trimmed);
    final targetBcp47 = _localeToBcp47(targetLocale);
    if (detected == null || detected == targetBcp47) {
      return text;
    }

    final cacheKey = '$detected->$targetBcp47::$trimmed';
    final cached = _memoryCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final sourceLang = _translateLanguageFromBcp47(detected);
    final targetLang = _translateLanguageFromBcp47(targetBcp47);
    if (sourceLang == null || targetLang == null) {
      // 言語マッピングができない場合は原文を返す
      return text;
    }

    // 翻訳実行前に、ソース・ターゲット両方のモデルが端末に必要
    await _downloadModelIfNeeded(detected);
    await _downloadModelIfNeeded(targetBcp47);

    final translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
    try {
      final out = await translator.translateText(trimmed);
      _memoryCache[cacheKey] = out;
      return out;
    } on Exception catch (_) {
      return text;
    } finally {
      // Platform リソースを解放
      await translator.close();
    }
  }

  /// 翻訳が必要かどうかを判定するユーティリティ。
  /// - 空文字は false
  /// - 言語判定不可は false
  /// - ソースとターゲットが同一言語なら false
  /// - それ以外は true
  Future<bool> shouldTranslate({
    required String text,
    required Locale targetLocale,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    final detected = await _safeIdentifyLanguage(trimmed);
    if (detected == null) {
      return false;
    }
    final targetBcp47 = _localeToBcp47(targetLocale);
    return detected != targetBcp47;
  }

  /// 文字列の言語を推定し、BCP-47 形式（正規化後）で返す。
  /// 'und'（未判定）や例外時は null を返す。
  Future<String?> _safeIdentifyLanguage(String text) async {
    try {
      final code = await _identifier.identifyLanguage(text);
      // LanguageIdentifier may return 'und' (undetermined)
      if (code == 'und' || code.isEmpty) {
        return null;
      }
      return _normalizeBcp47(code);
    } on Exception catch (_) {
      return null;
    }
  }

  /// BCP-47 を小文字言語 + 大文字地域の形式へ正規化する。
  /// 例: 'zh-tw' -> 'zh-TW'
  String _normalizeBcp47(String code) {
    // normalize case and region variants (e.g., zh-TW)
    final parts = code.split('-');
    if (parts.isEmpty) {
      return code.toLowerCase();
    }
    final language = parts[0].toLowerCase();
    if (parts.length == 1) {
      return language;
    }
    final region = parts[1].toUpperCase();
    return '$language-$region';
  }

  /// Flutter の Locale から BCP-47 文字列を生成する。
  /// countryCode が無い場合は言語のみ（例: 'ja'）。
  String _localeToBcp47(Locale locale) {
    if (locale.languageCode.isEmpty) {
      return 'en';
    }
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return locale.languageCode.toLowerCase();
    }
    final lang = locale.languageCode.toLowerCase();
    final region = locale.countryCode!.toUpperCase();
    return '$lang-$region';
  }

  /// BCP-47 から ML Kit の TranslateLanguage を推定する。
  /// 完全一致（例: 'zh-TW'）が無ければ、言語コード（例: 'zh'）で探索。
  /// 該当が無い場合は null。
  TranslateLanguage? _translateLanguageFromBcp47(String bcp47) {
    try {
      final normalized = _normalizeBcp47(bcp47);
      return TranslateLanguage.values.firstWhere(
        (lang) =>
            lang.bcpCode == normalized ||
            lang.bcpCode == normalized.split('-').first,
      );
    } on Exception catch (_) {
      return null;
    }
  }
}
