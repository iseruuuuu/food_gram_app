class URL {
  static const sns = 'https://x.com/FoodGram_dev';
  static const github = 'https://github.com/iseruuuuu/food_gram_app';
  static const appleStore =
      'https://apps.apple.com/hu/app/foodgram/id6474065183';
  static const googleStore =
      'https://play.google.com/store/apps/details?id=com.food_gram_app.com.com.com';
  static const faq =
      'https://succinct-may-e5e.notion.site/FAQ-256ae853b9ec4209a04f561449de8c1d';
  static const privacyPolicy =
      'https://succinct-may-e5e.notion.site/fd5584426bf44c50bdb1eb4b376d165f';
  static const termsOfUse =
      'https://succinct-may-e5e.notion.site/a0ad75abf8244404b7a19cca0e2304f1';
  static const contact = 'https://forms.gle/mjucjntt3c2SZsUc7';
  static const report =
      'https://docs.google.com/forms/d/1uDNHpaPTNPK7tBjbfNW87ykYH3JZO0D2l10oBtVxaQA/edit';

  static String go(String restaurant) =>
      'https://www.google.com/maps/search/?api=1&query=$restaurant';

  static String search(String restaurant) =>
      'https://www.google.com/search?q=$restaurant';
}
