import 'package:flutter_test/flutter_test.dart';
import 'package:food_gram_app/core/model/post_draft.dart';

void main() {
  group('PostDraftList version', () {
    test(
      'reads a version 2 list and keeps optional fields on version 1 items',
      () {
        const raw = '''
{"v":2,"items":[
 {"v":1,"foodName":"寿司","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":["sushi"],"star":3,"isAnonymous":false,"priceCurrency":"JPY"}
]}
''';

        final decoded = PostDraftList.decode(raw);

        expect(PostDraftList.isLegacyPayload(raw), isFalse);
        expect(decoded.items, hasLength(1));
        expect(decoded.items.single.id, 'legacy');
        expect(decoded.items.single.foodName, '寿司');
        expect(decoded.items.single.foodTags, ['sushi']);
      },
    );

    test(
      'rejects a list payload whose envelope version is missing or unsupported',
      () {
        const futureVersion = '''
{"v":999,"items":[
 {"v":1,"id":"1","savedAt":1,"foodName":"寿司","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"}
]}
''';
        const missingVersion = '''
{"items":[
 {"v":1,"id":"1","savedAt":1,"foodName":"寿司","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"}
]}
''';

        expect(PostDraftList.decode(futureVersion).items, isEmpty);
        expect(PostDraftList.decode(missingVersion).items, isEmpty);
        expect(PostDraftList.isLegacyPayload(futureVersion), isFalse);
        expect(PostDraftList.isLegacyPayload(missingVersion), isFalse);
      },
    );

    test('keeps the version 1 single-draft migration', () {
      const raw = '''
{"v":1,"foodName":"寿司","comment":"おいしい","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":3,"isAnonymous":false,"priceCurrency":"JPY"}
''';

      expect(PostDraftList.isLegacyPayload(raw), isTrue);
      expect(PostDraftList.decode(raw).items.single.foodName, '寿司');
    });

    test('rejects unsupported item versions inside a version 2 list', () {
      const raw = '''
{"v":2,"items":[
 {"v":1,"id":"ok","savedAt":1,"foodName":"寿司","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"},
 {"v":999,"id":"future","savedAt":1,"foodName":"未来","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"},
 {"id":"missing","savedAt":1,"foodName":"不明","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"}
]}
''';

      final decoded = PostDraftList.decode(raw);

      expect(decoded.items.map((item) => item.id), ['ok']);
    });

    test(
      'does not treat an unsupported single draft as a version 1 migration',
      () {
        const raw = '''
{"v":999,"foodName":"未来","comment":"","priceInput":"","restaurant":"場所を追加","lat":0,"lng":0,"foodTags":[],"star":1,"isAnonymous":false,"priceCurrency":"JPY"}
''';

        expect(PostDraftList.isLegacyPayload(raw), isFalse);
        expect(PostDraftList.decode(raw).items, isEmpty);
      },
    );
  });
}
