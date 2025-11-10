import 'l10n.dart';

extension L10nShareExtension on L10n {
  String get shareInviteMessage {
    switch (localeName) {
      case 'ja':
        return '美味しいフードをFoodGramでシェアしよう!';
      case 'es':
        return '¡Comparte comida deliciosa en FoodGram!';
      case 'fr':
        return 'Partage tes bons plats sur FoodGram !';
      case 'de':
        return 'Teile leckeres Essen auf FoodGram!';
      case 'ko':
        return '맛있는 음식을 FoodGram에서 공유해요!';
      case 'pt':
        return 'Compartilhe comida deliciosa no FoodGram!';
      case 'zh':
        return '在 FoodGram 分享美味吧！';
      case 'en':
      default:
        return 'Share delicious food on FoodGram!';
    }
  }
}

