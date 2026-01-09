import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_gram_app/core/supabase/current_user_provider.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_edge_client.g.dart';

/// Edge Function `UserFcmTokens` を取得する
/// 自分の投稿についた「いいね通知」の最新キー一覧を返す
class NotificationEdgeClient {
  NotificationEdgeClient(this._ref);
  final Ref _ref;

  SupabaseClient get _supabase => _ref.read(supabaseProvider);
  final Logger _logger = Logger();

  /// user_id の行を最大 limit=200 まで取得して返す
  Future<List<Map<String, dynamic>>> fetchUserFcmTokenRows(
    String userId,
  ) async {
    try {
      final res = await _supabase.functions.invoke(
        'UserFcmTokens',
        body: <String, dynamic>{
          'user_id': userId,
          'order': 'desc',
          'limit': 200,
        },
      );
      final rows = _unwrap(res.data);
      return rows.whereType<Map<String, dynamic>>().toList();
    } on Exception catch (e) {
      _logger.w('EdgeFunction UserFcmTokens に失敗しました: $e');
      return [];
    }
  }

  List<dynamic> _unwrap(dynamic data) {
    if (data == null) {
      return const [];
    }
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final d = data['data'];
      if (d is List) {
        return d;
      }
    }
    return const [];
  }
}

@riverpod
NotificationEdgeClient notificationEdgeClient(NotificationEdgeClientRef ref) {
  return NotificationEdgeClient(ref);
}
