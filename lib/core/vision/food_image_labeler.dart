import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class FoodImageLabeler {
  static const Set<String> _foodKeywords = {
    'Food',
    'Dish',
    'Cuisine',
    'Meal',
    'Ingredient',
    'Baked goods',
    'Drink',
    'Dessert',
  };

  Future<bool> isFood(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.6),
    );
    try {
      final labels = await labeler.processImage(input);
      for (final l in labels) {
        if (_foodKeywords.contains(l.label) && l.confidence >= 0.7) {
          return true;
        }
      }
      return false;
    } on Exception catch (_) {
      return true;
    } finally {
      await labeler.close();
    }
  }
}
