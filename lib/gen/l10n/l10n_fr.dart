// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get close => 'Fermer';

  @override
  String get cancel => 'Annuler';

  @override
  String get editTitle => 'Modifier';

  @override
  String get editPostButton => 'Modifier la Publication';

  @override
  String get emailInputField => 'Entrez votre adresse e-mail';

  @override
  String get settingIcon => 'Sélectionner l\'icône';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get userNameInputField => 'Nom d\'utilisateur (ex: iseryu)';

  @override
  String get userId => 'ID utilisateur';

  @override
  String get userIdInputField => 'ID utilisateur (ex: iseryuuu)';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get settingAppBar => 'Paramètres';

  @override
  String get settingCheckVersion => 'MàJ';

  @override
  String get settingCheckVersionDialogTitle => 'Informations de mise à jour';

  @override
  String get settingCheckVersionDialogText1 =>
      'Une nouvelle version est disponible.';

  @override
  String get settingCheckVersionDialogText2 =>
      'Veuillez mettre à jour vers la dernière version.';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'Noter';

  @override
  String get settingLicense => 'Licence';

  @override
  String get settingShareApp => 'Partager';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'Confidentialité';

  @override
  String get settingTermsOfUse => 'Conditions';

  @override
  String get settingContact => 'Contact';

  @override
  String get settingTutorial => 'Tutoriel';

  @override
  String get settingCredit => 'Crédits';

  @override
  String get unregistered => 'Non enregistré';

  @override
  String get settingBatteryLevel => 'Niveau de batterie';

  @override
  String get settingDeviceInfo => 'Informations sur l\'appareil';

  @override
  String get settingIosVersion => 'Version iOS';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'Version de l\'application';

  @override
  String get settingAccount => 'Compte';

  @override
  String get settingLogoutButton => 'Se déconnecter';

  @override
  String get settingDeleteAccountButton => 'Supprimer compte';

  @override
  String get settingQuestion => 'Questions';

  @override
  String get settingAccountManagement => 'Gestion du compte';

  @override
  String get settingRestoreSuccessTitle => 'Restauration réussie';

  @override
  String get settingRestoreSuccessSubtitle =>
      'Fonctionnalités premium activées !';

  @override
  String get settingRestoreFailureTitle => 'Échec de la restauration';

  @override
  String get settingRestoreFailureSubtitle =>
      'Aucun historique d\'achat ? Contactez le support';

  @override
  String get settingRestore => 'Restaurer';

  @override
  String get settingPremiumMembership => 'Devenez membre Premium';

  @override
  String get shareButton => 'Partager';

  @override
  String get postFoodName => 'Nom du plat';

  @override
  String get postFoodNameInputField => 'Entrez le nom du plat (Requis)';

  @override
  String get postRestaurantNameInputField => 'Ajouter un restaurant (Requis)';

  @override
  String get postComment => 'Entrez un commentaire (Optionnel)';

  @override
  String get postCommentInputField => 'Commentaire';

  @override
  String get postError => 'Échec de soumission';

  @override
  String get postCategoryTitle => 'Pays / Cuisine (optionnel)';

  @override
  String get postCountryCategory => 'Pays';

  @override
  String get postCuisineCategory => 'Cuisine';

  @override
  String get postTitle => 'Publier';

  @override
  String get postMissingInfo => 'Veuillez remplir tous les champs requis';

  @override
  String get postMissingPhoto => 'Veuillez ajouter une photo';

  @override
  String get postMissingFoodName => 'Veuillez entrer ce que vous avez mangé';

  @override
  String get postMissingRestaurant => 'Veuillez ajouter le nom du restaurant';

  @override
  String get postPhotoSuccess => 'Photo ajoutée avec succès';

  @override
  String get postCameraPermission => 'Permission d\'appareil photo requise';

  @override
  String get postAlbumPermission => 'Permission de bibliothèque photo requise';

  @override
  String get postSuccess => 'Publication réussie';

  @override
  String get postSearchError => 'Impossible de rechercher les noms de lieux';

  @override
  String get editUpdateButton => 'Mettre à jour';

  @override
  String get editBio => 'Biographie (optionnel)';

  @override
  String get editBioInputField => 'Entrez la biographie';

  @override
  String get editFavoriteTagTitle => 'Sélectionner l\'étiquette favorite';

  @override
  String get emptyPosts => 'Aucune publication';

  @override
  String get searchEmptyResult => 'Aucun résultat trouvé pour votre recherche.';

  @override
  String get searchButton => 'Recherche';

  @override
  String get searchTitle => 'Rechercher';

  @override
  String get searchRestaurantTitle => 'Rechercher des restaurants';

  @override
  String get searchUserTitle => 'Recherche d\'utilisateurs';

  @override
  String get searchUserHeader => 'Utilisateurs (par posts)';

  @override
  String searchUserPostCount(Object count) {
    return 'Publications: $count';
  }

  @override
  String get searchUserLatestPosts => 'Dernières publications';

  @override
  String get searchUserNoUsers =>
      'Aucun utilisateur avec des publications trouvé';

  @override
  String get unknown => 'Inconnu・Aucun résultat';

  @override
  String get profilePostCount => 'Publications';

  @override
  String get profilePointCount => 'Points';

  @override
  String get profileEditButton => 'Modifier le profil';

  @override
  String get profileExchangePointsButton => 'Échanger des points';

  @override
  String get profileFavoriteGenre => 'Genre favori';

  @override
  String get likeButton => 'J\'aime';

  @override
  String get shareReviewPrefix =>
      'Je viens de partager mon avis sur ce que j\'ai mangé !';

  @override
  String get shareReviewSuffix => 'Pour plus, jetez un œil à foodGram !';

  @override
  String get postDetailSheetTitle => 'À propos de cette publication';

  @override
  String get postDetailSheetShareButton => 'Partager cette publication';

  @override
  String get postDetailSheetReportButton => 'Signaler cette publication';

  @override
  String get postDetailSheetBlockButton => 'Bloquer cet utilisateur';

  @override
  String get dialogYesButton => 'Oui';

  @override
  String get dialogNoButton => 'Non';

  @override
  String get dialogReportTitle => 'Signaler une publication';

  @override
  String get dialogReportDescription1 => 'Vous signalerez cette publication.';

  @override
  String get dialogReportDescription2 =>
      'Vous serez dirigé vers un formulaire Google.';

  @override
  String get dialogBlockTitle => 'Confirmation de blocage';

  @override
  String get dialogBlockDescription1 => 'Voulez-vous bloquer cet utilisateur ?';

  @override
  String get dialogBlockDescription2 =>
      'Cela masquera les publications de l\'utilisateur.';

  @override
  String get dialogBlockDescription3 =>
      'Les utilisateurs bloqués seront sauvegardés localement.';

  @override
  String get dialogDeleteTitle => 'Supprimer la publication';

  @override
  String get heartLimitMessage =>
      'Vous avez atteint la limite de 10 j\'aime d\'aujourd\'hui. Veuillez réessayer demain.';

  @override
  String get dialogDeleteDescription1 =>
      'Voulez-vous supprimer cette publication ?';

  @override
  String get dialogDeleteDescription2 =>
      'Une fois supprimée, elle ne peut pas être restaurée.';

  @override
  String get dialogDeleteError => 'Échec de la suppression.';

  @override
  String get dialogLogoutTitle => 'Confirmer la déconnexion';

  @override
  String get dialogLogoutDescription1 => 'Voulez-vous vous déconnecter ?';

  @override
  String get dialogLogoutDescription2 =>
      'L\'état du compte est stocké sur le serveur.';

  @override
  String get dialogLogoutButton => 'Se déconnecter';

  @override
  String get errorTitle => 'Erreur de communication';

  @override
  String get errorDescription1 => 'Une erreur de connexion s\'est produite.';

  @override
  String get errorDescription2 =>
      'Vérifiez votre connexion réseau et réessayez.';

  @override
  String get errorRefreshButton => 'Recharger';

  @override
  String get error => 'Des erreurs se sont produites';

  @override
  String get mapLoadingError => 'Une erreur s\'est produite';

  @override
  String get mapLoadingRestaurant =>
      'Obtention des informations du restaurant...';

  @override
  String get appShareTitle => 'Partager';

  @override
  String get appShareStoreButton => 'Partager ce magasin';

  @override
  String get appShareInstagramButton => 'Partager sur Instagram';

  @override
  String get appShareGoButton => 'Aller à ce magasin';

  @override
  String get appShareCloseButton => 'Fermer';

  @override
  String get shareInviteMessage => 'Partage tes bons plats sur FoodGram !';

  @override
  String get appRestaurantLabel => 'Rechercher restaurant';

  @override
  String get appRequestTitle => '🙇 Activez l\'emplacement actuel 🙇';

  @override
  String get appRequestReason =>
      'Les données d\'emplacement actuelles sont nécessaires pour la sélection de restaurants';

  @override
  String get appRequestInduction =>
      'Les boutons suivants vous mèneront à l\'écran des paramètres';

  @override
  String get appRequestOpenSetting => 'Ouvrir l\'écran des paramètres';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'Manger × Photo × Partager';

  @override
  String get agreeToTheTermsOfUse =>
      'Veuillez accepter les conditions d\'utilisation';

  @override
  String get restaurantCategoryList => 'Sélectionner une cuisine par pays';

  @override
  String get cookingCategoryList => 'Sélectionner une étiquette de nourriture';

  @override
  String get restaurantReviewNew => 'Nouveau';

  @override
  String get restaurantReviewViewDetails => 'Voir les détails';

  @override
  String get restaurantReviewOtherPosts => 'Autres publications';

  @override
  String get restaurantReviewReviewList => 'Liste des avis';

  @override
  String get restaurantReviewError => 'Une erreur s\'est produite';

  @override
  String get nearbyRestaurants => '📍Restaurants à proximité';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get selectCountryTag => 'Tags pays';

  @override
  String get selectFavoriteTag => 'Sélectionner l\'étiquette favorite';

  @override
  String get favoriteTagPlaceholder => 'Sélectionnez votre étiquette favorite';

  @override
  String get selectFoodTag => 'Tags cuisine';

  @override
  String get tabHome => 'Nourriture';

  @override
  String get tabMap => 'Carte';

  @override
  String get tabMyMap => 'Ma Carte';

  @override
  String get tabSearch => 'Rechercher';

  @override
  String get tabMyPage => 'Ma page';

  @override
  String get tabSetting => 'Paramètres';

  @override
  String get mapStatsVisitedArea => 'Zones';

  @override
  String get mapStatsPosts => 'Posts';

  @override
  String get mapStatsActivityDays => 'Jours';

  @override
  String get dayUnit => 'jours';

  @override
  String get mapStatsPrefectures => 'Préfectures';

  @override
  String get mapStatsAchievementRate => 'Taux';

  @override
  String get mapStatsVisitedCountries => 'Pays';

  @override
  String get mapViewTypeRecord => 'Record';

  @override
  String get mapViewTypeJapan => 'Japon';

  @override
  String get mapViewTypeWorld => 'Monde';

  @override
  String get logoutFailure => 'Échec de la déconnexion';

  @override
  String get accountDeletionFailure => 'Échec de la suppression du compte';

  @override
  String get appleLoginFailure => 'Connexion Apple non disponible';

  @override
  String get emailAuthenticationFailure =>
      'Échec de l\'authentification par e-mail';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get loginSuccessful => 'Connexion réussie';

  @override
  String get emailAuthentication =>
      'Authentifiez-vous avec votre application e-mail';

  @override
  String get emailEmpty => 'Aucune adresse e-mail n\'a été saisie';

  @override
  String get email => 'Adresse e-mail';

  @override
  String get enterTheCorrectFormat => 'Veuillez entrer le format correct';

  @override
  String get authInvalidFormat =>
      'Le format de l\'adresse e-mail est incorrect.';

  @override
  String get authSocketException =>
      'Il y a un problème avec le réseau. Veuillez vérifier la connexion.';

  @override
  String get camera => 'Caméra';

  @override
  String get album => 'Album';

  @override
  String get snsLogin => 'Connexion SNS';

  @override
  String get tutorialFirstPageTitle => 'Partage tes moments';

  @override
  String get tutorialFirstPageSubTitle =>
      'Avec FoodGram, chaque repas devient spécial.';

  @override
  String get tutorialDiscoverTitle => 'Trouve ton meilleur plat !';

  @override
  String get tutorialDiscoverSubTitle =>
      'À chaque scroll, une découverte gourmande.';

  @override
  String get tutorialSecondPageTitle => 'La food map exclusive';

  @override
  String get tutorialSecondPageSubTitle => 'Ta map évolue avec tes posts.';

  @override
  String get tutorialThirdPageTitle => 'Conditions d\'utilisation';

  @override
  String get tutorialThirdPageSubTitle =>
      '・Soyez prudent lors du partage d\'informations personnelles telles que nom, adresse, numéro de téléphone ou emplacement.\n\n・Évitez de publier du contenu offensant, inapproprié ou nuisible, et n\'utilisez pas les œuvres d\'autrui sans permission.\n\n・Les publications non liées à la nourriture peuvent être supprimées.\n\n・Les utilisateurs qui violent répétitivement les règles ou publient du contenu répréhensible peuvent être supprimés par l\'équipe de gestion.\n\n・Nous attendons avec impatience d\'améliorer cette application avec tout le monde. par les développeurs';

  @override
  String get tutorialThirdPageButton => 'Accepter';

  @override
  String get tutorialThirdPageClose => 'Fermer';

  @override
  String get detailMenuShare => 'Partager';

  @override
  String get detailMenuVisit => 'Visiter';

  @override
  String get detailMenuPost => 'Publier';

  @override
  String get detailMenuSearch => 'Rechercher';

  @override
  String get forceUpdateTitle => 'Notification de mise à jour';

  @override
  String get forceUpdateText =>
      'Une nouvelle version de cette application a été publiée. Veuillez mettre à jour l\'application pour assurer les dernières fonctionnalités et un environnement sécurisé.';

  @override
  String get forceUpdateButtonTitle => 'Mettre à jour';

  @override
  String get newAccountImportantTitle => 'Note importante';

  @override
  String get newAccountImportant =>
      'Lors de la création d\'un compte, veuillez ne pas inclure d\'informations personnelles telles que l\'adresse e-mail ou le numéro de téléphone dans votre nom d\'utilisateur ou ID utilisateur. Pour assurer une expérience en ligne sûre, choisissez un nom qui ne révèle pas vos détails personnels.';

  @override
  String get accountRegistrationSuccess => 'Inscription du compte terminée';

  @override
  String get accountRegistrationError => 'Une erreur s\'est produite';

  @override
  String get requiredInfoMissing => 'Informations requises manquantes';

  @override
  String get shareTextAndImage => 'Partager avec texte et image';

  @override
  String get shareImageOnly => 'Partager image uniquement';

  @override
  String get foodCategoryNoodles => 'Nouilles';

  @override
  String get foodCategoryMeat => 'Viande';

  @override
  String get foodCategoryFastFood => 'Fast-food';

  @override
  String get foodCategoryRiceDishes => 'Plats de riz';

  @override
  String get foodCategorySeafood => 'Fruits de mer';

  @override
  String get foodCategoryBread => 'Pain';

  @override
  String get foodCategorySweetsAndSnacks => 'Bonbons et collations';

  @override
  String get foodCategoryFruits => 'Fruits';

  @override
  String get foodCategoryVegetables => 'Légumes';

  @override
  String get foodCategoryBeverages => 'Boissons';

  @override
  String get foodCategoryOthers => 'Autres';

  @override
  String get foodCategoryAll => 'TOUT';

  @override
  String get rankEmerald => 'Émeraude';

  @override
  String get rankDiamond => 'Diamant';

  @override
  String get rankGold => 'Or';

  @override
  String get rankSilver => 'Argent';

  @override
  String get rankBronze => 'Bronze';

  @override
  String get rank => 'Rang';

  @override
  String get promoteDialogTitle => '✨Devenez membre premium✨';

  @override
  String get promoteDialogTrophyTitle => 'Fonction trophée';

  @override
  String get promoteDialogTrophyDesc =>
      'Affiche les trophées basés sur vos activités.';

  @override
  String get promoteDialogTagTitle => 'Étiquettes personnalisées';

  @override
  String get promoteDialogTagDesc =>
      'Définissez des étiquettes personnalisées pour vos aliments préférés.';

  @override
  String get promoteDialogIconTitle => 'Icône personnalisée';

  @override
  String get promoteDialogIconDesc =>
      'Définissez votre icône de profil sur n\'importe quelle image que vous aimez !!';

  @override
  String get promoteDialogAdTitle => 'Sans publicité';

  @override
  String get promoteDialogAdDesc => 'Supprime toutes les publicités !!';

  @override
  String get promoteDialogButton => 'Devenir premium';

  @override
  String get promoteDialogLater => 'Peut-être plus tard';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ Avantages Premium ✨';

  @override
  String get paywallTrophyTitle => 'Gagne des titres en publiant plus';

  @override
  String get paywallTrophyDesc =>
      'Les titres évoluent avec ton nombre de posts';

  @override
  String get paywallTagTitle => 'Définis tes genres favoris';

  @override
  String get paywallTagDesc => 'Personnalise davantage ton profil';

  @override
  String get paywallIconTitle => 'Utilise une image comme icône';

  @override
  String get paywallIconDesc => 'Démarque-toi des autres auteurs';

  @override
  String get paywallAdTitle => 'Sans publicité';

  @override
  String get paywallAdDesc => 'Supprime toutes les publicités';

  @override
  String get paywallComingSoon => 'Bientôt disponible...';

  @override
  String get paywallNewFeatures =>
      'Nouvelles fonctionnalités exclusives premium\nbientôt disponibles !';

  @override
  String get paywallSubscribeButton => 'Devenir membre premium';

  @override
  String get paywallPrice => 'mensuel \$3 / mois';

  @override
  String get paywallCancelNote => 'Annuler à tout moment';

  @override
  String get paywallWelcomeTitle => 'Bienvenue chez\nFoodGram Members !';

  @override
  String get paywallSkip => 'Passer';

  @override
  String get purchaseError => 'Une erreur s\'est produite lors de l\'achat';

  @override
  String get paywallTagline => '✨ Améliore ton expérience culinaire ✨';

  @override
  String get paywallMapTitle => 'Chercher avec la carte';

  @override
  String get paywallMapDesc =>
      'Trouve des restaurants plus vite et plus facilement';

  @override
  String get paywallRankTitle => 'Gagne des titres en publiant plus';

  @override
  String get paywallRankDesc => 'Les titres évoluent avec ton nombre de posts';

  @override
  String get paywallGenreTitle => 'Définis tes genres favoris';

  @override
  String get paywallGenreDesc => 'Personnalise davantage ton profil';

  @override
  String get paywallCustomIconTitle => 'Utilise une image comme icône';

  @override
  String get paywallCustomIconDesc => 'Démarque-toi des autres auteurs';

  @override
  String get anonymousPost => 'Publier anonymement';

  @override
  String get anonymousPostDescription => 'Le nom d\'utilisateur sera masqué';

  @override
  String get anonymousShare => 'Partager anonymement';

  @override
  String get anonymousUpdate => 'Mettre à jour anonymement';

  @override
  String get anonymousPoster => 'Auteur anonyme';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'Autre cuisine';

  @override
  String get tagOtherFood => 'Autre nourriture';

  @override
  String get tagJapaneseCuisine => 'Cuisine japonaise';

  @override
  String get tagItalianCuisine => 'Cuisine italienne';

  @override
  String get tagFrenchCuisine => 'Cuisine française';

  @override
  String get tagChineseCuisine => 'Cuisine chinoise';

  @override
  String get tagIndianCuisine => 'Cuisine indienne';

  @override
  String get tagMexicanCuisine => 'Cuisine mexicaine';

  @override
  String get tagHongKongCuisine => 'Cuisine de Hong Kong';

  @override
  String get tagAmericanCuisine => 'Cuisine américaine';

  @override
  String get tagMediterraneanCuisine => 'Cuisine méditerranéenne';

  @override
  String get tagThaiCuisine => 'Cuisine thaïlandaise';

  @override
  String get tagGreekCuisine => 'Cuisine grecque';

  @override
  String get tagTurkishCuisine => 'Cuisine turque';

  @override
  String get tagKoreanCuisine => 'Cuisine coréenne';

  @override
  String get tagRussianCuisine => 'Cuisine russe';

  @override
  String get tagSpanishCuisine => 'Cuisine espagnole';

  @override
  String get tagVietnameseCuisine => 'Cuisine vietnamienne';

  @override
  String get tagPortugueseCuisine => 'Cuisine portugaise';

  @override
  String get tagAustrianCuisine => 'Cuisine autrichienne';

  @override
  String get tagBelgianCuisine => 'Cuisine belge';

  @override
  String get tagSwedishCuisine => 'Cuisine suédoise';

  @override
  String get tagGermanCuisine => 'Cuisine allemande';

  @override
  String get tagBritishCuisine => 'Cuisine britannique';

  @override
  String get tagDutchCuisine => 'Cuisine néerlandaise';

  @override
  String get tagAustralianCuisine => 'Cuisine australienne';

  @override
  String get tagBrazilianCuisine => 'Cuisine brésilienne';

  @override
  String get tagArgentineCuisine => 'Cuisine argentine';

  @override
  String get tagColombianCuisine => 'Cuisine colombienne';

  @override
  String get tagPeruvianCuisine => 'Cuisine péruvienne';

  @override
  String get tagNorwegianCuisine => 'Cuisine norvégienne';

  @override
  String get tagDanishCuisine => 'Cuisine danoise';

  @override
  String get tagPolishCuisine => 'Cuisine polonaise';

  @override
  String get tagCzechCuisine => 'Cuisine tchèque';

  @override
  String get tagHungarianCuisine => 'Cuisine hongroise';

  @override
  String get tagSouthAfricanCuisine => 'Cuisine sud-africaine';

  @override
  String get tagEgyptianCuisine => 'Cuisine égyptienne';

  @override
  String get tagMoroccanCuisine => 'Cuisine marocaine';

  @override
  String get tagNewZealandCuisine => 'Cuisine néo-zélandaise';

  @override
  String get tagFilipinoCuisine => 'Cuisine philippine';

  @override
  String get tagMalaysianCuisine => 'Cuisine malaisienne';

  @override
  String get tagSingaporeanCuisine => 'Cuisine singapourienne';

  @override
  String get tagIndonesianCuisine => 'Cuisine indonésienne';

  @override
  String get tagIranianCuisine => 'Cuisine iranienne';

  @override
  String get tagSaudiArabianCuisine => 'Cuisine saoudienne';

  @override
  String get tagMongolianCuisine => 'Cuisine mongole';

  @override
  String get tagCambodianCuisine => 'Cuisine cambodgienne';

  @override
  String get tagLaotianCuisine => 'Cuisine laotienne';

  @override
  String get tagCubanCuisine => 'Cuisine cubaine';

  @override
  String get tagJamaicanCuisine => 'Cuisine jamaïcaine';

  @override
  String get tagChileanCuisine => 'Cuisine chilienne';

  @override
  String get tagVenezuelanCuisine => 'Cuisine vénézuélienne';

  @override
  String get tagPanamanianCuisine => 'Cuisine panaméenne';

  @override
  String get tagBolivianCuisine => 'Cuisine bolivienne';

  @override
  String get tagIcelandicCuisine => 'Cuisine islandaise';

  @override
  String get tagLithuanianCuisine => 'Cuisine lituanienne';

  @override
  String get tagEstonianCuisine => 'Cuisine estonienne';

  @override
  String get tagLatvianCuisine => 'Cuisine lettone';

  @override
  String get tagFinnishCuisine => 'Cuisine finlandaise';

  @override
  String get tagCroatianCuisine => 'Cuisine croate';

  @override
  String get tagSlovenianCuisine => 'Cuisine slovène';

  @override
  String get tagSlovakCuisine => 'Cuisine slovaque';

  @override
  String get tagRomanianCuisine => 'Cuisine roumaine';

  @override
  String get tagBulgarianCuisine => 'Cuisine bulgare';

  @override
  String get tagSerbianCuisine => 'Cuisine serbe';

  @override
  String get tagAlbanianCuisine => 'Cuisine albanaise';

  @override
  String get tagGeorgianCuisine => 'Cuisine géorgienne';

  @override
  String get tagArmenianCuisine => 'Cuisine arménienne';

  @override
  String get tagAzerbaijaniCuisine => 'Cuisine azerbaïdjanaise';

  @override
  String get tagUkrainianCuisine => 'Cuisine ukrainienne';

  @override
  String get tagBelarusianCuisine => 'Cuisine biélorusse';

  @override
  String get tagKazakhCuisine => 'Cuisine kazakhe';

  @override
  String get tagUzbekCuisine => 'Cuisine ouzbèke';

  @override
  String get tagKyrgyzCuisine => 'Cuisine kirghize';

  @override
  String get tagTurkmenCuisine => 'Cuisine turkmène';

  @override
  String get tagTajikCuisine => 'Cuisine tadjike';

  @override
  String get tagMaldivianCuisine => 'Cuisine maldivienne';

  @override
  String get tagNepaleseCuisine => 'Cuisine népalaise';

  @override
  String get tagBangladeshiCuisine => 'Cuisine bangladaise';

  @override
  String get tagMyanmarCuisine => 'Cuisine birmane';

  @override
  String get tagBruneianCuisine => 'Cuisine bruneienne';

  @override
  String get tagTaiwaneseCuisine => 'Cuisine taïwanaise';

  @override
  String get tagNigerianCuisine => 'Cuisine nigériane';

  @override
  String get tagKenyanCuisine => 'Cuisine kényane';

  @override
  String get tagGhanaianCuisine => 'Cuisine ghanéenne';

  @override
  String get tagEthiopianCuisine => 'Cuisine éthiopienne';

  @override
  String get tagSudaneseCuisine => 'Cuisine soudanaise';

  @override
  String get tagTunisianCuisine => 'Cuisine tunisienne';

  @override
  String get tagAngolanCuisine => 'Cuisine angolaise';

  @override
  String get tagCongoleseCuisine => 'Cuisine congolaise';

  @override
  String get tagZimbabweanCuisine => 'Cuisine zimbabwéenne';

  @override
  String get tagMalagasyCuisine => 'Cuisine malgache';

  @override
  String get tagPapuaNewGuineanCuisine => 'Cuisine papouasienne';

  @override
  String get tagSamoanCuisine => 'Cuisine samoane';

  @override
  String get tagTuvaluanCuisine => 'Cuisine tuvaluane';

  @override
  String get tagFijianCuisine => 'Cuisine fidjienne';

  @override
  String get tagPalauanCuisine => 'Cuisine palauane';

  @override
  String get tagKiribatiCuisine => 'Cuisine kiribatienne';

  @override
  String get tagVanuatuanCuisine => 'Cuisine vanuatuane';

  @override
  String get tagBahrainiCuisine => 'Cuisine bahreïnienne';

  @override
  String get tagQatariCuisine => 'Cuisine qatarie';

  @override
  String get tagKuwaitiCuisine => 'Cuisine koweïtienne';

  @override
  String get tagOmaniCuisine => 'Cuisine omanaise';

  @override
  String get tagYemeniCuisine => 'Cuisine yéménite';

  @override
  String get tagLebaneseCuisine => 'Cuisine libanaise';

  @override
  String get tagSyrianCuisine => 'Cuisine syrienne';

  @override
  String get tagJordanianCuisine => 'Cuisine jordanienne';

  @override
  String get tagNoodles => 'Nouilles';

  @override
  String get tagMeatDishes => 'Plats de viande';

  @override
  String get tagFastFood => 'Fast-food';

  @override
  String get tagRiceDishes => 'Plats de riz';

  @override
  String get tagSeafood => 'Fruits de mer';

  @override
  String get tagBread => 'Pain';

  @override
  String get tagSweetsAndSnacks => 'Bonbons et collations';

  @override
  String get tagFruits => 'Fruits';

  @override
  String get tagVegetables => 'Légumes';

  @override
  String get tagBeverages => 'Boissons';

  @override
  String get tagOthers => 'Autres';

  @override
  String get tagPasta => 'Pâtes';

  @override
  String get tagRamen => 'Ramen';

  @override
  String get tagSteak => 'Steak';

  @override
  String get tagYakiniku => 'Yakiniku';

  @override
  String get tagChicken => 'Poulet';

  @override
  String get tagBacon => 'Bacon';

  @override
  String get tagHamburger => 'Hamburger';

  @override
  String get tagFrenchFries => 'Frites';

  @override
  String get tagPizza => 'Pizza';

  @override
  String get tagTacos => 'Tacos';

  @override
  String get tagTamales => 'Tamales';

  @override
  String get tagGyoza => 'Gyoza';

  @override
  String get tagFriedShrimp => 'Crevettes frites';

  @override
  String get tagHotPot => 'Marmite';

  @override
  String get tagCurry => 'Curry';

  @override
  String get tagPaella => 'Paella';

  @override
  String get tagFondue => 'Fondue';

  @override
  String get tagOnigiri => 'Onigiri';

  @override
  String get tagRice => 'Riz';

  @override
  String get tagBento => 'Bento';

  @override
  String get tagSushi => 'Sushi';

  @override
  String get tagFish => 'Poisson';

  @override
  String get tagOctopus => 'Poulpe';

  @override
  String get tagSquid => 'Calamar';

  @override
  String get tagShrimp => 'Crevettes';

  @override
  String get tagCrab => 'Crabe';

  @override
  String get tagShellfish => 'Coquillages';

  @override
  String get tagOyster => 'Huître';

  @override
  String get tagSandwich => 'Sandwich';

  @override
  String get tagHotDog => 'Hot-dog';

  @override
  String get tagDonut => 'Donut';

  @override
  String get tagPancake => 'Crêpe';

  @override
  String get tagCroissant => 'Croissant';

  @override
  String get tagBagel => 'Bagel';

  @override
  String get tagBaguette => 'Baguette';

  @override
  String get tagPretzel => 'Bretzel';

  @override
  String get tagBurrito => 'Burrito';

  @override
  String get tagIceCream => 'Crème glacée';

  @override
  String get tagPudding => 'Pudding';

  @override
  String get tagRiceCracker => 'Cracker de riz';

  @override
  String get tagDango => 'Dango';

  @override
  String get tagShavedIce => 'Glace pilée';

  @override
  String get tagPie => 'Tarte';

  @override
  String get tagCupcake => 'Cupcake';

  @override
  String get tagCake => 'Gâteau';

  @override
  String get tagCandy => 'Bonbon';

  @override
  String get tagLollipop => 'Sucette';

  @override
  String get tagChocolate => 'Chocolat';

  @override
  String get tagPopcorn => 'Pop-corn';

  @override
  String get tagCookie => 'Cookie';

  @override
  String get tagPeanuts => 'Cacahuètes';

  @override
  String get tagBeans => 'Haricots';

  @override
  String get tagChestnut => 'Châtaigne';

  @override
  String get tagFortuneCookie => 'Cookie de fortune';

  @override
  String get tagMooncake => 'Gâteau de lune';

  @override
  String get tagHoney => 'Miel';

  @override
  String get tagWaffle => 'Gaufre';

  @override
  String get tagApple => 'Pomme';

  @override
  String get tagPear => 'Poire';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagLemon => 'Citron';

  @override
  String get tagLime => 'Citron vert';

  @override
  String get tagBanana => 'Banane';

  @override
  String get tagWatermelon => 'Pastèque';

  @override
  String get tagGrapes => 'Raisins';

  @override
  String get tagStrawberry => 'Fraise';

  @override
  String get tagBlueberry => 'Myrtille';

  @override
  String get tagMelon => 'Melon';

  @override
  String get tagCherry => 'Cerise';

  @override
  String get tagPeach => 'Pêche';

  @override
  String get tagMango => 'Mangue';

  @override
  String get tagPineapple => 'Ananas';

  @override
  String get tagCoconut => 'Noix de coco';

  @override
  String get tagKiwi => 'Kiwi';

  @override
  String get tagSalad => 'Salade';

  @override
  String get tagTomato => 'Tomate';

  @override
  String get tagEggplant => 'Aubergine';

  @override
  String get tagAvocado => 'Avocat';

  @override
  String get tagGreenBeans => 'Haricots verts';

  @override
  String get tagBroccoli => 'Brocoli';

  @override
  String get tagLettuce => 'Laitue';

  @override
  String get tagCucumber => 'Concombre';

  @override
  String get tagChili => 'Piment';

  @override
  String get tagBellPepper => 'Poivron';

  @override
  String get tagCorn => 'Maïs';

  @override
  String get tagCarrot => 'Carotte';

  @override
  String get tagOlive => 'Olive';

  @override
  String get tagGarlic => 'Ail';

  @override
  String get tagOnion => 'Oignon';

  @override
  String get tagPotato => 'Pomme de terre';

  @override
  String get tagSweetPotato => 'Patate douce';

  @override
  String get tagGinger => 'Gingembre';

  @override
  String get tagShiitake => 'Shiitake';

  @override
  String get tagTeapot => 'Théière';

  @override
  String get tagCoffee => 'Café';

  @override
  String get tagTea => 'Thé';

  @override
  String get tagJuice => 'Jus';

  @override
  String get tagSoftDrink => 'Boisson gazeuse';

  @override
  String get tagBubbleTea => 'Thé aux perles';

  @override
  String get tagSake => 'Saké';

  @override
  String get tagBeer => 'Bière';

  @override
  String get tagChampagne => 'Champagne';

  @override
  String get tagWine => 'Vin';

  @override
  String get tagWhiskey => 'Whisky';

  @override
  String get tagCocktail => 'Cocktail';

  @override
  String get tagTropicalCocktail => 'Cocktail tropical';

  @override
  String get tagMateTea => 'Thé maté';

  @override
  String get tagMilk => 'Lait';

  @override
  String get tagKamaboko => 'Kamaboko';

  @override
  String get tagOden => 'Oden';

  @override
  String get tagCheese => 'Fromage';

  @override
  String get tagEgg => 'Œuf';

  @override
  String get tagFriedEgg => 'Œuf au plat';

  @override
  String get tagButter => 'Beurre';

  @override
  String get done => 'Terminé';

  @override
  String get save => 'Enregistrer';

  @override
  String get searchFood => 'Rechercher de la nourriture';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get searchCountry => 'Rechercher un pays';

  @override
  String get searchEmptyTitle => 'Entrez le nom du restaurant pour rechercher';

  @override
  String get searchEmptyHintTitle => 'Conseils de recherche';

  @override
  String get searchEmptyHintLocation =>
      'Activez l\'emplacement pour afficher d\'abord les résultats à proximité';

  @override
  String get searchEmptyHintSearch =>
      'Recherchez par nom de restaurant ou type de cuisine';

  @override
  String get postErrorPickImage => 'Échec de la prise de photo';

  @override
  String get favoritePostEmptyTitle => 'Aucune publication sauvegardée';

  @override
  String get favoritePostEmptySubtitle =>
      'Sauvegardez les publications qui vous intéressent !';

  @override
  String get userInfoFetchError =>
      'Échec de la récupération des informations utilisateur';

  @override
  String get saved => 'Sauvegardé';

  @override
  String get savedPosts => 'Publications sauvegardées';

  @override
  String get postSaved => 'Publication sauvegardée';

  @override
  String get postSavedMessage =>
      'Vous pouvez voir les publications sauvegardées dans Ma page';

  @override
  String get noMapAppAvailable => 'Aucune application de carte disponible';

  @override
  String get notificationLunchTitle =>
      '#Avez-vous déjà posté le repas d\'aujourd\'hui ? 🍜';

  @override
  String get notificationLunchBody =>
      'Pourquoi ne pas enregistrer le déjeuner d\'aujourd\'hui tant que vous vous en souvenez ?';

  @override
  String get notificationDinnerTitle =>
      '#Avez-vous déjà posté le repas d\'aujourd\'hui ? 🍛';

  @override
  String get notificationDinnerBody =>
      'Postez le repas d\'aujourd\'hui et terminez la journée en douceur 📷';

  @override
  String get posted => 'publié';

  @override
  String get tutorialLocationTitle => 'Activer la localisation !';

  @override
  String get tutorialLocationSubTitle =>
      'Pour trouver de bons endroits à proximité,\nfacilitez la recherche de restaurants';

  @override
  String get tutorialLocationButton => 'Activer';

  @override
  String get tutorialNotificationTitle => 'Activer les notifications !';

  @override
  String get tutorialNotificationSubTitle =>
      'Nous enverrons des rappels au déjeuner et au dîner';

  @override
  String get tutorialNotificationButton => 'Activer les notifications';

  @override
  String get selectMapApp => 'Sélectionner l\'application de carte';

  @override
  String get mapAppGoogle => 'Google Maps';

  @override
  String get mapAppApple => 'Apple Maps';

  @override
  String get mapAppBaidu => 'Baidu Maps';

  @override
  String get mapAppMapsMe => 'Maps.me';

  @override
  String get mapAppKakao => 'KakaoMap';

  @override
  String get mapAppNaver => 'Naver Map';

  @override
  String get streakDialogFirstTitle => 'Publication terminée';

  @override
  String get streakDialogFirstContent =>
      'Continuez à publier\npour maintenir série';

  @override
  String get streakDialogContinueTitle => 'Publication terminée';

  @override
  String streakDialogContinueContent(int weeks) {
    return '$weeks semaines consécutives !\nContinuez à publier\npour maintenir série';
  }
}
