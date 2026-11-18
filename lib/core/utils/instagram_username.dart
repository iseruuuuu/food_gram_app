/// Instagram のアカウント名。空文字は未設定、不正な入力は null。
String? normalizeInstagramUsername(String raw) {
  var value = _stripAt(raw.trim());
  if (value.isEmpty) {
    return '';
  }

  if (value.toLowerCase().contains('instagram.com')) {
    final parsed = Uri.tryParse(
      value.contains('://') ? value : 'https://$value',
    );
    final host = parsed?.host.toLowerCase() ?? '';
    final isInstagram =
        host == 'instagram.com' ||
        host == 'www.instagram.com' ||
        host.endsWith('.instagram.com');
    if (parsed != null && isInstagram) {
      final segments = parsed.pathSegments
          .where((segment) => segment.isNotEmpty)
          .toList();
      if (segments.isEmpty) {
        return '';
      }
      const reserved = {
        'p',
        'reel',
        'reels',
        'stories',
        'explore',
        'accounts',
        'direct',
      };
      if (reserved.contains(segments.first.toLowerCase())) {
        return null;
      }
      value = _stripAt(segments.first.trim());
    }
  }

  if (value.isEmpty) {
    return '';
  }
  if (!_isValidInstagramUsername(value)) {
    return null;
  }
  return value;
}

Uri instagramAppUri(String username) {
  return Uri(
    scheme: 'instagram',
    host: 'user',
    queryParameters: {'username': username},
  );
}

Uri instagramWebUri(String username) {
  return Uri.https('www.instagram.com', '/$username/');
}

String _stripAt(String value) {
  if (value.startsWith('@') || value.startsWith('＠')) {
    return value.substring(1).trim();
  }
  return value;
}

bool _isValidInstagramUsername(String value) {
  if (value.startsWith('.') || value.endsWith('.') || value.contains('..')) {
    return false;
  }
  return RegExp(r'^[A-Za-z0-9._]{1,30}$').hasMatch(value);
}
