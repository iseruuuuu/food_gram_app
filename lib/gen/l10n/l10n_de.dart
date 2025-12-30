// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get maybeNotFoodDialogTitle => 'Kurze Bestätigung 🍽️';

  @override
  String get maybeNotFoodDialogText =>
      'Dieses Foto zeigt möglicherweise kein Essen… 🤔\\n\\nTrotzdem posten?';

  @override
  String get maybeNotFoodDialogConfirm => 'Fortfahren';

  @override
  String get maybeNotFoodDialogDelete => 'Bild löschen';

  @override
  String get close => 'Schließen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get editTitle => 'Bearbeiten';

  @override
  String get editPostButton => 'Beitrag bearbeiten';

  @override
  String get emailInputField => 'Geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get settingIcon => 'Symbol auswählen';

  @override
  String get userName => 'Benutzername';

  @override
  String get userNameInputField => 'Benutzername (z.B. iseryu)';

  @override
  String get userId => 'Benutzer-ID';

  @override
  String get userIdInputField => 'Benutzer-ID (z.B. iseryuuu)';

  @override
  String get registerButton => 'Registrieren';

  @override
  String get settingAppBar => 'Einstellungen';

  @override
  String get settingCheckVersion => 'Aktualisieren';

  @override
  String get settingCheckVersionDialogTitle => 'Update-Informationen';

  @override
  String get settingCheckVersionDialogText1 =>
      'Eine neue Version ist verfügbar.';

  @override
  String get settingCheckVersionDialogText2 =>
      'Bitte aktualisieren Sie auf die neueste Version.';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'Bewerten';

  @override
  String get settingLicense => 'Lizenz';

  @override
  String get settingShareApp => 'Teilen';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'Datenschutz';

  @override
  String get settingTermsOfUse => 'Bedingungen';

  @override
  String get settingContact => 'Kontakt';

  @override
  String get settingTutorial => 'Tutorial';

  @override
  String get settingCredit => 'Credits';

  @override
  String get unregistered => 'Nicht registriert';

  @override
  String get settingBatteryLevel => 'Batteriestand';

  @override
  String get settingDeviceInfo => 'Geräteinformationen';

  @override
  String get settingIosVersion => 'iOS-Version';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'App-Version';

  @override
  String get settingAccount => 'Konto';

  @override
  String get settingLogoutButton => 'Abmelden';

  @override
  String get settingDeleteAccountButton => 'Konto löschen';

  @override
  String get settingQuestion => 'Fragebox';

  @override
  String get settingAccountManagement => 'Kontoverwaltung';

  @override
  String get settingRestoreSuccessTitle => 'Wiederherstellung erfolgreich';

  @override
  String get settingRestoreSuccessSubtitle => 'Premium-Funktionen aktiviert!';

  @override
  String get settingRestoreFailureTitle => 'Wiederherstellung fehlgeschlagen';

  @override
  String get settingRestoreFailureSubtitle =>
      'Keine Kaufhistorie? Kontaktieren Sie den Support';

  @override
  String get settingRestore => 'Wiederherstellen';

  @override
  String get settingPremiumMembership => 'Premium-Mitglied werden';

  @override
  String get shareButton => 'Teilen';

  @override
  String get postFoodName => 'Essensname';

  @override
  String get postFoodNameInputField => 'Essen eingeben (Pflicht)';

  @override
  String get postRestaurantNameInputField => 'Restaurant hinzufügen (Pflicht)';

  @override
  String get postComment => 'Kommentar eingeben (Optional)';

  @override
  String get postCommentInputField => 'Kommentar';

  @override
  String get postError => 'Übermittlung fehlgeschlagen';

  @override
  String get postCategoryTitle => 'Land/Küche-Tag wählen (Optional)';

  @override
  String get postCountryCategory => 'Land';

  @override
  String get postCuisineCategory => 'Küche';

  @override
  String get postTitle => 'Veröffentlichen';

  @override
  String get postMissingInfo =>
      'Bitte füllen Sie alle erforderlichen Felder aus';

  @override
  String get postMissingPhoto => 'Bitte fügen Sie ein Foto hinzu';

  @override
  String get postMissingFoodName =>
      'Bitte geben Sie ein, was Sie gegessen haben';

  @override
  String get postMissingRestaurant =>
      'Bitte fügen Sie den Restaurantnamen hinzu';

  @override
  String get postPhotoSuccess => 'Foto erfolgreich hinzugefügt';

  @override
  String get postCameraPermission => 'Kamera-Berechtigung erforderlich';

  @override
  String get postAlbumPermission => 'Foto-Bibliothek-Berechtigung erforderlich';

  @override
  String get postSuccess => 'Veröffentlichung erfolgreich';

  @override
  String get postSearchError => 'Ortsnamen können nicht gesucht werden';

  @override
  String get editUpdateButton => 'Aktualisieren';

  @override
  String get editBio => 'Biografie (optional)';

  @override
  String get editBioInputField => 'Biografie eingeben';

  @override
  String get editFavoriteTagTitle => 'Lieblings-Etikett auswählen';

  @override
  String get emptyPosts => 'Keine Beiträge';

  @override
  String get searchEmptyResult => 'Keine Ergebnisse für Ihre Suche gefunden.';

  @override
  String get searchButton => 'Suchen';

  @override
  String get searchTitle => 'Suchen';

  @override
  String get searchRestaurantTitle => 'Restaurants suchen';

  @override
  String get searchUserTitle => 'Benutzersuche';

  @override
  String get searchUserHeader => 'Benutzersuche (nach Beitragszahl)';

  @override
  String searchUserPostCount(Object count) {
    return 'Beiträge: $count';
  }

  @override
  String get searchUserLatestPosts => 'Neueste Beiträge';

  @override
  String get searchUserNoUsers => 'Keine Benutzer mit Beiträgen gefunden';

  @override
  String get unknown => 'Unbekannt・Keine Ergebnisse';

  @override
  String get profilePostCount => 'Beiträge';

  @override
  String get profilePointCount => 'Punkte';

  @override
  String get profileEditButton => 'Profil bearbeiten';

  @override
  String get profileExchangePointsButton => 'Punkte einlösen';

  @override
  String get profileFavoriteGenre => 'Lieblingsgenre';

  @override
  String get likeButton => 'Gefällt mir';

  @override
  String get shareReviewPrefix =>
      'Ich habe gerade meine Bewertung von dem, was ich gegessen habe, geteilt!';

  @override
  String get shareReviewSuffix => 'Für mehr schauen Sie sich foodGram an!';

  @override
  String get postDetailSheetTitle => 'Über diesen Beitrag';

  @override
  String get postDetailSheetShareButton => 'Diesen Beitrag teilen';

  @override
  String get postDetailSheetReportButton => 'Diesen Beitrag melden';

  @override
  String get postDetailSheetBlockButton => 'Diesen Benutzer blockieren';

  @override
  String get dialogYesButton => 'Ja';

  @override
  String get dialogNoButton => 'Nein';

  @override
  String get dialogReportTitle => 'Beitrag melden';

  @override
  String get dialogReportDescription1 => 'Sie werden diesen Beitrag melden.';

  @override
  String get dialogReportDescription2 =>
      'Sie werden zu einem Google-Formular weitergeleitet.';

  @override
  String get dialogBlockTitle => 'Blockierung bestätigen';

  @override
  String get dialogBlockDescription1 =>
      'Möchten Sie diesen Benutzer blockieren?';

  @override
  String get dialogBlockDescription2 =>
      'Dies wird die Beiträge des Benutzers ausblenden.';

  @override
  String get dialogBlockDescription3 =>
      'Blockierte Benutzer werden lokal gespeichert.';

  @override
  String get dialogDeleteTitle => 'Beitrag löschen';

  @override
  String get heartLimitMessage =>
      'Sie haben das heutige Limit von 10 Likes erreicht. Bitte versuchen Sie es morgen erneut.';

  @override
  String get dialogDeleteDescription1 => 'Möchten Sie diesen Beitrag löschen?';

  @override
  String get dialogDeleteDescription2 =>
      'Einmal gelöscht, kann er nicht wiederhergestellt werden.';

  @override
  String get dialogDeleteError => 'Löschung fehlgeschlagen.';

  @override
  String get dialogLogoutTitle => 'Abmeldung bestätigen';

  @override
  String get dialogLogoutDescription1 => 'Möchten Sie sich abmelden?';

  @override
  String get dialogLogoutDescription2 =>
      'Der Kontostatus wird auf dem Server gespeichert.';

  @override
  String get dialogLogoutButton => 'Abmelden';

  @override
  String get errorTitle => 'Kommunikationsfehler';

  @override
  String get errorDescription1 => 'Ein Verbindungsfehler ist aufgetreten.';

  @override
  String get errorDescription2 =>
      'Überprüfen Sie Ihre Netzwerkverbindung und versuchen Sie es erneut.';

  @override
  String get errorRefreshButton => 'Neu laden';

  @override
  String get error => 'Fehler sind aufgetreten';

  @override
  String get mapLoadingError => 'Ein Fehler ist aufgetreten';

  @override
  String get mapLoadingRestaurant =>
      'Restaurant-Informationen werden abgerufen...';

  @override
  String get appShareTitle => 'Teilen';

  @override
  String get appShareStoreButton => 'Diesen Laden teilen';

  @override
  String get appShareInstagramButton => 'Auf Instagram teilen';

  @override
  String get appShareGoButton => 'Zu diesem Laden gehen';

  @override
  String get appShareCloseButton => 'Schließen';

  @override
  String get shareInviteMessage => 'Teile leckeres Essen auf FoodGram!';

  @override
  String get appRestaurantLabel => 'Restaurant suchen';

  @override
  String get appRequestTitle => '🙇 Aktivieren Sie den aktuellen Standort 🙇';

  @override
  String get appRequestReason =>
      'Aktuelle Standortdaten sind für die Restaurantauswahl erforderlich';

  @override
  String get appRequestInduction =>
      'Die folgenden Schaltflächen führen Sie zum Einstellungsbildschirm';

  @override
  String get appRequestOpenSetting => 'Einstellungsbildschirm öffnen';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'Essen × Schnapp × Teilen';

  @override
  String get agreeToTheTermsOfUse =>
      'Bitte stimmen Sie den Nutzungsbedingungen zu';

  @override
  String get restaurantCategoryList => 'Küche nach Land auswählen';

  @override
  String get cookingCategoryList => 'Essens-Etikett auswählen';

  @override
  String get restaurantReviewNew => 'Neu';

  @override
  String get restaurantReviewViewDetails => 'Details anzeigen';

  @override
  String get restaurantReviewOtherPosts => 'Andere Beiträge';

  @override
  String get restaurantReviewReviewList => 'Bewertungsliste';

  @override
  String get restaurantReviewError => 'Ein Fehler ist aufgetreten';

  @override
  String get nearbyRestaurants => '📍Restaurants in der Nähe';

  @override
  String get seeMore => 'Mehr anzeigen';

  @override
  String get selectCountryTag => 'Land-Etikett auswählen';

  @override
  String get selectFavoriteTag => 'Lieblings-Etikett auswählen';

  @override
  String get favoriteTagPlaceholder => 'Wählen Sie Ihr Lieblings-Etikett';

  @override
  String get selectFoodTag => 'Essens-Etikett auswählen';

  @override
  String get tabHome => 'Essen';

  @override
  String get tabMap => 'Karte';

  @override
  String get tabMyMap => 'Meine Karte';

  @override
  String get tabSearch => 'Suchen';

  @override
  String get tabMyPage => 'Meine Seite';

  @override
  String get tabSetting => 'Einstellungen';

  @override
  String get mapStatsVisitedArea => 'Gebiete';

  @override
  String get mapStatsPosts => 'Posts';

  @override
  String get mapStatsActivityDays => 'Tage';

  @override
  String get dayUnit => 'Tage';

  @override
  String get mapStatsPrefectures => 'Präfekturen';

  @override
  String get mapStatsAchievementRate => 'Rate';

  @override
  String get mapStatsVisitedCountries => 'Länder';

  @override
  String get mapViewTypeRecord => 'Aufzeichnung';

  @override
  String get mapViewTypeJapan => 'Japan';

  @override
  String get mapViewTypeWorld => 'Welt';

  @override
  String get logoutFailure => 'Abmeldung fehlgeschlagen';

  @override
  String get accountDeletionFailure => 'Kontolöschung fehlgeschlagen';

  @override
  String get appleLoginFailure => 'Apple-Anmeldung nicht verfügbar';

  @override
  String get emailAuthenticationFailure =>
      'E-Mail-Authentifizierung fehlgeschlagen';

  @override
  String get loginError => 'Anmeldefehler';

  @override
  String get loginSuccessful => 'Anmeldung erfolgreich';

  @override
  String get emailAuthentication =>
      'Authentifizieren Sie sich mit Ihrer E-Mail-App';

  @override
  String get emailEmpty => 'Keine E-Mail-Adresse eingegeben';

  @override
  String get email => 'E-Mail-Adresse';

  @override
  String get enterTheCorrectFormat => 'Bitte geben Sie das richtige Format ein';

  @override
  String get authInvalidFormat => 'Das Format der E-Mail-Adresse ist falsch.';

  @override
  String get authSocketException =>
      'Es gibt ein Problem mit dem Netzwerk. Bitte überprüfen Sie die Verbindung.';

  @override
  String get camera => 'Kamera';

  @override
  String get album => 'Album';

  @override
  String get snsLogin => 'SNS-Anmeldung';

  @override
  String get tutorialFirstPageTitle => 'Köstliche Momente teilen';

  @override
  String get tutorialFirstPageSubTitle =>
      'Jede Mahlzeit wird besonderer.\nEntdecken Sie neue Geschmäcker!';

  @override
  String get tutorialDiscoverTitle => 'Ihr nächstes Lieblingsgericht!';

  @override
  String get tutorialDiscoverSubTitle =>
      'Neue Entdeckungen bei jedem Scrollen.\nKöstliches Essen finden.';

  @override
  String get tutorialSecondPageTitle => 'Einzigartige Essenskarte';

  @override
  String get tutorialSecondPageSubTitle =>
      'Erstellen Sie eine einzigartige Karte.\nIhre Beiträge entwickeln die Karte.';

  @override
  String get tutorialThirdPageTitle => 'Nutzungsbedingungen';

  @override
  String get tutorialThirdPageSubTitle =>
      '・Seien Sie vorsichtig beim Teilen persönlicher Informationen wie Name, Adresse, Telefonnummer oder Standort.\n\n・Vermeiden Sie das Veröffentlichen anstößiger, unangemessener oder schädlicher Inhalte und verwenden Sie nicht die Werke anderer ohne Erlaubnis.\n\n・Beiträge, die nicht mit Essen zusammenhängen, können gelöscht werden.\n\n・Benutzer, die wiederholt gegen die Regeln verstoßen oder anstößige Inhalte veröffentlichen, können vom Management-Team entfernt werden.\n\n・Wir freuen uns darauf, diese App mit allen zu verbessern. von den Entwicklern';

  @override
  String get tutorialThirdPageButton => 'Akzeptieren';

  @override
  String get tutorialThirdPageClose => 'Schließen';

  @override
  String get detailMenuShare => 'Teilen';

  @override
  String get detailMenuVisit => 'Besuchen';

  @override
  String get detailMenuPost => 'Veröffentlichen';

  @override
  String get detailMenuSearch => 'Suchen';

  @override
  String get forceUpdateTitle => 'Update-Benachrichtigung';

  @override
  String get forceUpdateText =>
      'Eine neue Version dieser App wurde veröffentlicht. Bitte aktualisieren Sie die App, um die neuesten Funktionen und eine sichere Umgebung zu gewährleisten.';

  @override
  String get forceUpdateButtonTitle => 'Aktualisieren';

  @override
  String get newAccountImportantTitle => 'Wichtiger Hinweis';

  @override
  String get newAccountImportant =>
      'Beim Erstellen eines Kontos fügen Sie bitte keine persönlichen Informationen wie E-Mail-Adresse oder Telefonnummer in Ihren Benutzernamen oder Ihre Benutzer-ID ein. Für eine sichere Online-Erfahrung wählen Sie einen Namen, der Ihre persönlichen Details nicht preisgibt.';

  @override
  String get accountRegistrationSuccess => 'Kontoregistrierung abgeschlossen';

  @override
  String get accountRegistrationError => 'Ein Fehler ist aufgetreten';

  @override
  String get requiredInfoMissing => 'Erforderliche Informationen fehlen';

  @override
  String get shareTextAndImage => 'Mit Text und Bild teilen';

  @override
  String get shareImageOnly => 'Nur Bild teilen';

  @override
  String get foodCategoryNoodles => 'Nudeln';

  @override
  String get foodCategoryMeat => 'Fleisch';

  @override
  String get foodCategoryFastFood => 'Fast Food';

  @override
  String get foodCategoryRiceDishes => 'Reisgerichte';

  @override
  String get foodCategorySeafood => 'Meeresfrüchte';

  @override
  String get foodCategoryBread => 'Brot';

  @override
  String get foodCategorySweetsAndSnacks => 'Süßigkeiten und Snacks';

  @override
  String get foodCategoryFruits => 'Obst';

  @override
  String get foodCategoryVegetables => 'Gemüse';

  @override
  String get foodCategoryBeverages => 'Getränke';

  @override
  String get foodCategoryOthers => 'Andere';

  @override
  String get foodCategoryAll => 'ALLE';

  @override
  String get rankEmerald => 'Smaragd';

  @override
  String get rankDiamond => 'Diamant';

  @override
  String get rankGold => 'Gold';

  @override
  String get rankSilver => 'Silber';

  @override
  String get rankBronze => 'Bronze';

  @override
  String get rank => 'Rang';

  @override
  String get promoteDialogTitle => '✨Werden Sie Premium-Mitglied✨';

  @override
  String get promoteDialogTrophyTitle => 'Trophäen-Funktion';

  @override
  String get promoteDialogTrophyDesc =>
      'Zeigt Trophäen basierend auf Ihren Aktivitäten an.';

  @override
  String get promoteDialogTagTitle => 'Benutzerdefinierte Tags';

  @override
  String get promoteDialogTagDesc =>
      'Legen Sie benutzerdefinierte Tags für Ihre Lieblingsspeisen fest.';

  @override
  String get promoteDialogIconTitle => 'Benutzerdefiniertes Symbol';

  @override
  String get promoteDialogIconDesc =>
      'Legen Sie Ihr Profilsymbol auf ein beliebiges Bild fest, das Sie mögen !!';

  @override
  String get promoteDialogAdTitle => 'Werbefrei';

  @override
  String get promoteDialogAdDesc => 'Entfernt alle Werbung !!';

  @override
  String get promoteDialogButton => 'Premium werden';

  @override
  String get promoteDialogLater => 'Vielleicht später';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ Premium-Vorteile ✨';

  @override
  String get paywallTrophyTitle => 'Verdiene Titel mit mehr Beiträgen';

  @override
  String get paywallTrophyDesc => 'Titel steigen mit deiner Beitragszahl';

  @override
  String get paywallTagTitle => 'Lieblingsgenres festlegen';

  @override
  String get paywallTagDesc => 'Profil stilvoll personalisieren';

  @override
  String get paywallIconTitle => 'Beliebiges Bild als Icon nutzen';

  @override
  String get paywallIconDesc => 'Hebe dich von anderen ab';

  @override
  String get paywallAdTitle => 'Werbefrei';

  @override
  String get paywallAdDesc => 'Entfernt alle Werbung';

  @override
  String get paywallComingSoon => 'Demnächst verfügbar...';

  @override
  String get paywallNewFeatures =>
      'Neue Premium-exklusive Funktionen\nkommen bald!';

  @override
  String get paywallSubscribeButton => 'Premium-Mitglied werden';

  @override
  String get paywallPrice => 'monatlich \$3 / Monat';

  @override
  String get paywallCancelNote => 'Jederzeit kündbar';

  @override
  String get paywallWelcomeTitle => 'Willkommen bei\nFoodGram Members!';

  @override
  String get paywallSkip => 'Überspringen';

  @override
  String get purchaseError => 'Beim Kauf ist ein Fehler aufgetreten';

  @override
  String get paywallTagline => '✨ Dein Food-Erlebnis upgraden ✨';

  @override
  String get paywallMapTitle => 'Mit Karte suchen';

  @override
  String get paywallMapDesc => 'Finde Restaurants schneller und einfacher';

  @override
  String get paywallRankTitle => 'Verdiene Titel mit mehr Beiträgen';

  @override
  String get paywallRankDesc => 'Titel steigen mit deiner Beitragszahl';

  @override
  String get paywallGenreTitle => 'Lieblingsgenres festlegen';

  @override
  String get paywallGenreDesc => 'Profil stilvoll personalisieren';

  @override
  String get paywallCustomIconTitle => 'Beliebiges Bild als Icon nutzen';

  @override
  String get paywallCustomIconDesc => 'Hebe dich von anderen ab';

  @override
  String get anonymousPost => 'Anonym veröffentlichen';

  @override
  String get anonymousPostDescription => 'Benutzername wird ausgeblendet';

  @override
  String get anonymousShare => 'Anonym teilen';

  @override
  String get anonymousUpdate => 'Anonym aktualisieren';

  @override
  String get anonymousPoster => 'Anonymer Autor';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'Andere Küche';

  @override
  String get tagOtherFood => 'Anderes Essen';

  @override
  String get tagJapaneseCuisine => 'Japanische Küche';

  @override
  String get tagItalianCuisine => 'Italienische Küche';

  @override
  String get tagFrenchCuisine => 'Französische Küche';

  @override
  String get tagChineseCuisine => 'Chinesische Küche';

  @override
  String get tagIndianCuisine => 'Indische Küche';

  @override
  String get tagMexicanCuisine => 'Mexikanische Küche';

  @override
  String get tagHongKongCuisine => 'Hongkong-Küche';

  @override
  String get tagAmericanCuisine => 'Amerikanische Küche';

  @override
  String get tagMediterraneanCuisine => 'Mittelmeerküche';

  @override
  String get tagThaiCuisine => 'Thailändische Küche';

  @override
  String get tagGreekCuisine => 'Griechische Küche';

  @override
  String get tagTurkishCuisine => 'Türkische Küche';

  @override
  String get tagKoreanCuisine => 'Koreanische Küche';

  @override
  String get tagRussianCuisine => 'Russische Küche';

  @override
  String get tagSpanishCuisine => 'Spanische Küche';

  @override
  String get tagVietnameseCuisine => 'Vietnamesische Küche';

  @override
  String get tagPortugueseCuisine => 'Portugiesische Küche';

  @override
  String get tagAustrianCuisine => 'Österreichische Küche';

  @override
  String get tagBelgianCuisine => 'Belgische Küche';

  @override
  String get tagSwedishCuisine => 'Schwedische Küche';

  @override
  String get tagGermanCuisine => 'Deutsche Küche';

  @override
  String get tagBritishCuisine => 'Britische Küche';

  @override
  String get tagDutchCuisine => 'Niederländische Küche';

  @override
  String get tagAustralianCuisine => 'Australische Küche';

  @override
  String get tagBrazilianCuisine => 'Brasilianische Küche';

  @override
  String get tagArgentineCuisine => 'Argentinische Küche';

  @override
  String get tagColombianCuisine => 'Kolumbianische Küche';

  @override
  String get tagPeruvianCuisine => 'Peruanische Küche';

  @override
  String get tagNorwegianCuisine => 'Norwegische Küche';

  @override
  String get tagDanishCuisine => 'Dänische Küche';

  @override
  String get tagPolishCuisine => 'Polnische Küche';

  @override
  String get tagCzechCuisine => 'Tschechische Küche';

  @override
  String get tagHungarianCuisine => 'Ungarische Küche';

  @override
  String get tagSouthAfricanCuisine => 'Südafrikanische Küche';

  @override
  String get tagEgyptianCuisine => 'Ägyptische Küche';

  @override
  String get tagMoroccanCuisine => 'Marokkanische Küche';

  @override
  String get tagNewZealandCuisine => 'Neuseeländische Küche';

  @override
  String get tagFilipinoCuisine => 'Philippinische Küche';

  @override
  String get tagMalaysianCuisine => 'Malaysische Küche';

  @override
  String get tagSingaporeanCuisine => 'Singapur-Küche';

  @override
  String get tagIndonesianCuisine => 'Indonesische Küche';

  @override
  String get tagIranianCuisine => 'Iranische Küche';

  @override
  String get tagSaudiArabianCuisine => 'Saudi-Arabische Küche';

  @override
  String get tagMongolianCuisine => 'Mongolische Küche';

  @override
  String get tagCambodianCuisine => 'Kambodschanische Küche';

  @override
  String get tagLaotianCuisine => 'Laotische Küche';

  @override
  String get tagCubanCuisine => 'Kubanische Küche';

  @override
  String get tagJamaicanCuisine => 'Jamaikanische Küche';

  @override
  String get tagChileanCuisine => 'Chilenische Küche';

  @override
  String get tagVenezuelanCuisine => 'Venezolanische Küche';

  @override
  String get tagPanamanianCuisine => 'Panamaische Küche';

  @override
  String get tagBolivianCuisine => 'Bolivianische Küche';

  @override
  String get tagIcelandicCuisine => 'Isländische Küche';

  @override
  String get tagLithuanianCuisine => 'Litauische Küche';

  @override
  String get tagEstonianCuisine => 'Estnische Küche';

  @override
  String get tagLatvianCuisine => 'Lettische Küche';

  @override
  String get tagFinnishCuisine => 'Finnische Küche';

  @override
  String get tagCroatianCuisine => 'Kroatische Küche';

  @override
  String get tagSlovenianCuisine => 'Slowenische Küche';

  @override
  String get tagSlovakCuisine => 'Slowakische Küche';

  @override
  String get tagRomanianCuisine => 'Rumänische Küche';

  @override
  String get tagBulgarianCuisine => 'Bulgarische Küche';

  @override
  String get tagSerbianCuisine => 'Serbische Küche';

  @override
  String get tagAlbanianCuisine => 'Albanische Küche';

  @override
  String get tagGeorgianCuisine => 'Georgische Küche';

  @override
  String get tagArmenianCuisine => 'Armenische Küche';

  @override
  String get tagAzerbaijaniCuisine => 'Aserbaidschanische Küche';

  @override
  String get tagUkrainianCuisine => 'Ukrainische Küche';

  @override
  String get tagBelarusianCuisine => 'Weißrussische Küche';

  @override
  String get tagKazakhCuisine => 'Kasachische Küche';

  @override
  String get tagUzbekCuisine => 'Usbekische Küche';

  @override
  String get tagKyrgyzCuisine => 'Kirgisische Küche';

  @override
  String get tagTurkmenCuisine => 'Turkmenische Küche';

  @override
  String get tagTajikCuisine => 'Tadschikische Küche';

  @override
  String get tagMaldivianCuisine => 'Maledivische Küche';

  @override
  String get tagNepaleseCuisine => 'Nepalesische Küche';

  @override
  String get tagBangladeshiCuisine => 'Bangladeschische Küche';

  @override
  String get tagMyanmarCuisine => 'Myanmarische Küche';

  @override
  String get tagBruneianCuisine => 'Brunei-Küche';

  @override
  String get tagTaiwaneseCuisine => 'Taiwanesische Küche';

  @override
  String get tagNigerianCuisine => 'Nigerianische Küche';

  @override
  String get tagKenyanCuisine => 'Kenia-Küche';

  @override
  String get tagGhanaianCuisine => 'Ghanaische Küche';

  @override
  String get tagEthiopianCuisine => 'Äthiopische Küche';

  @override
  String get tagSudaneseCuisine => 'Sudanesische Küche';

  @override
  String get tagTunisianCuisine => 'Tunesische Küche';

  @override
  String get tagAngolanCuisine => 'Angolanische Küche';

  @override
  String get tagCongoleseCuisine => 'Kongolesische Küche';

  @override
  String get tagZimbabweanCuisine => 'Simbabwe-Küche';

  @override
  String get tagMalagasyCuisine => 'Madagassische Küche';

  @override
  String get tagPapuaNewGuineanCuisine => 'Papua-Neuguinea-Küche';

  @override
  String get tagSamoanCuisine => 'Samoanische Küche';

  @override
  String get tagTuvaluanCuisine => 'Tuvalu-Küche';

  @override
  String get tagFijianCuisine => 'Fidschi-Küche';

  @override
  String get tagPalauanCuisine => 'Palau-Küche';

  @override
  String get tagKiribatiCuisine => 'Kiribati-Küche';

  @override
  String get tagVanuatuanCuisine => 'Vanuatu-Küche';

  @override
  String get tagBahrainiCuisine => 'Bahrainische Küche';

  @override
  String get tagQatariCuisine => 'Katarische Küche';

  @override
  String get tagKuwaitiCuisine => 'Kuwaitische Küche';

  @override
  String get tagOmaniCuisine => 'Omanische Küche';

  @override
  String get tagYemeniCuisine => 'Jemenitische Küche';

  @override
  String get tagLebaneseCuisine => 'Libanesische Küche';

  @override
  String get tagSyrianCuisine => 'Syrische Küche';

  @override
  String get tagJordanianCuisine => 'Jordanische Küche';

  @override
  String get tagNoodles => 'Nudeln';

  @override
  String get tagMeatDishes => 'Fleischgerichte';

  @override
  String get tagFastFood => 'Fast Food';

  @override
  String get tagRiceDishes => 'Reisgerichte';

  @override
  String get tagSeafood => 'Meeresfrüchte';

  @override
  String get tagBread => 'Brot';

  @override
  String get tagSweetsAndSnacks => 'Süßigkeiten und Snacks';

  @override
  String get tagFruits => 'Obst';

  @override
  String get tagVegetables => 'Gemüse';

  @override
  String get tagBeverages => 'Getränke';

  @override
  String get tagOthers => 'Andere';

  @override
  String get tagPasta => 'Pasta';

  @override
  String get tagRamen => 'Ramen';

  @override
  String get tagSteak => 'Steak';

  @override
  String get tagYakiniku => 'Yakiniku';

  @override
  String get tagChicken => 'Huhn';

  @override
  String get tagBacon => 'Speck';

  @override
  String get tagHamburger => 'Hamburger';

  @override
  String get tagFrenchFries => 'Pommes Frites';

  @override
  String get tagPizza => 'Pizza';

  @override
  String get tagTacos => 'Tacos';

  @override
  String get tagTamales => 'Tamales';

  @override
  String get tagGyoza => 'Gyoza';

  @override
  String get tagFriedShrimp => 'Gebratene Garnelen';

  @override
  String get tagHotPot => 'Hot Pot';

  @override
  String get tagCurry => 'Curry';

  @override
  String get tagPaella => 'Paella';

  @override
  String get tagFondue => 'Fondue';

  @override
  String get tagOnigiri => 'Onigiri';

  @override
  String get tagRice => 'Reis';

  @override
  String get tagBento => 'Bento';

  @override
  String get tagSushi => 'Sushi';

  @override
  String get tagFish => 'Fisch';

  @override
  String get tagOctopus => 'Oktopus';

  @override
  String get tagSquid => 'Tintenfisch';

  @override
  String get tagShrimp => 'Garnelen';

  @override
  String get tagCrab => 'Krabbe';

  @override
  String get tagShellfish => 'Schalentiere';

  @override
  String get tagOyster => 'Auster';

  @override
  String get tagSandwich => 'Sandwich';

  @override
  String get tagHotDog => 'Hot Dog';

  @override
  String get tagDonut => 'Donut';

  @override
  String get tagPancake => 'Pfannkuchen';

  @override
  String get tagCroissant => 'Croissant';

  @override
  String get tagBagel => 'Bagel';

  @override
  String get tagBaguette => 'Baguette';

  @override
  String get tagPretzel => 'Brezel';

  @override
  String get tagBurrito => 'Burrito';

  @override
  String get tagIceCream => 'Eiscreme';

  @override
  String get tagPudding => 'Pudding';

  @override
  String get tagRiceCracker => 'Reiskracker';

  @override
  String get tagDango => 'Dango';

  @override
  String get tagShavedIce => 'Eisstückchen';

  @override
  String get tagPie => 'Kuchen';

  @override
  String get tagCupcake => 'Cupcake';

  @override
  String get tagCake => 'Kuchen';

  @override
  String get tagCandy => 'Süßigkeit';

  @override
  String get tagLollipop => 'Lutscher';

  @override
  String get tagChocolate => 'Schokolade';

  @override
  String get tagPopcorn => 'Popcorn';

  @override
  String get tagCookie => 'Keks';

  @override
  String get tagPeanuts => 'Erdnüsse';

  @override
  String get tagBeans => 'Bohnen';

  @override
  String get tagChestnut => 'Kastanie';

  @override
  String get tagFortuneCookie => 'Glückskeks';

  @override
  String get tagMooncake => 'Mondkuchen';

  @override
  String get tagHoney => 'Honig';

  @override
  String get tagWaffle => 'Waffel';

  @override
  String get tagApple => 'Apfel';

  @override
  String get tagPear => 'Birne';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagLemon => 'Zitrone';

  @override
  String get tagLime => 'Limette';

  @override
  String get tagBanana => 'Banane';

  @override
  String get tagWatermelon => 'Wassermelone';

  @override
  String get tagGrapes => 'Trauben';

  @override
  String get tagStrawberry => 'Erdbeere';

  @override
  String get tagBlueberry => 'Heidelbeere';

  @override
  String get tagMelon => 'Melone';

  @override
  String get tagCherry => 'Kirsche';

  @override
  String get tagPeach => 'Pfirsich';

  @override
  String get tagMango => 'Mango';

  @override
  String get tagPineapple => 'Ananas';

  @override
  String get tagCoconut => 'Kokosnuss';

  @override
  String get tagKiwi => 'Kiwi';

  @override
  String get tagSalad => 'Salat';

  @override
  String get tagTomato => 'Tomate';

  @override
  String get tagEggplant => 'Aubergine';

  @override
  String get tagAvocado => 'Avocado';

  @override
  String get tagGreenBeans => 'Grüne Bohnen';

  @override
  String get tagBroccoli => 'Brokkoli';

  @override
  String get tagLettuce => 'Salat';

  @override
  String get tagCucumber => 'Gurke';

  @override
  String get tagChili => 'Chili';

  @override
  String get tagBellPepper => 'Paprika';

  @override
  String get tagCorn => 'Mais';

  @override
  String get tagCarrot => 'Karotte';

  @override
  String get tagOlive => 'Olive';

  @override
  String get tagGarlic => 'Knoblauch';

  @override
  String get tagOnion => 'Zwiebel';

  @override
  String get tagPotato => 'Kartoffel';

  @override
  String get tagSweetPotato => 'Süßkartoffel';

  @override
  String get tagGinger => 'Ingwer';

  @override
  String get tagShiitake => 'Shiitake';

  @override
  String get tagTeapot => 'Teekanne';

  @override
  String get tagCoffee => 'Kaffee';

  @override
  String get tagTea => 'Tee';

  @override
  String get tagJuice => 'Saft';

  @override
  String get tagSoftDrink => 'Erfrischungsgetränk';

  @override
  String get tagBubbleTea => 'Bubble Tea';

  @override
  String get tagSake => 'Sake';

  @override
  String get tagBeer => 'Bier';

  @override
  String get tagChampagne => 'Champagner';

  @override
  String get tagWine => 'Wein';

  @override
  String get tagWhiskey => 'Whisky';

  @override
  String get tagCocktail => 'Cocktail';

  @override
  String get tagTropicalCocktail => 'Tropischer Cocktail';

  @override
  String get tagMateTea => 'Mate-Tee';

  @override
  String get tagMilk => 'Milch';

  @override
  String get tagKamaboko => 'Kamaboko';

  @override
  String get tagOden => 'Oden';

  @override
  String get tagCheese => 'Käse';

  @override
  String get tagEgg => 'Ei';

  @override
  String get tagFriedEgg => 'Spiegelei';

  @override
  String get tagButter => 'Butter';

  @override
  String get done => 'Fertig';

  @override
  String get save => 'Speichern';

  @override
  String get searchFood => 'Essen suchen';

  @override
  String get noResultsFound => 'Keine Ergebnisse gefunden';

  @override
  String get searchCountry => 'Land suchen';

  @override
  String get searchEmptyTitle =>
      'Geben Sie den Restaurantnamen ein, um zu suchen';

  @override
  String get searchEmptyHintTitle => 'Suchtipps';

  @override
  String get searchEmptyHintLocation =>
      'Aktivieren Sie den Standort, um zuerst nahegelegene Ergebnisse anzuzeigen';

  @override
  String get searchEmptyHintSearch =>
      'Suchen Sie nach Restaurantname oder Küchentyp';

  @override
  String get postErrorPickImage => 'Fotoaufnahme fehlgeschlagen';

  @override
  String get favoritePostEmptyTitle => 'Keine gespeicherten Beiträge';

  @override
  String get favoritePostEmptySubtitle =>
      'Speichern Sie Beiträge, die Sie interessieren!';

  @override
  String get userInfoFetchError =>
      'Fehler beim Abrufen der Benutzerinformationen';

  @override
  String get saved => 'Gespeichert';

  @override
  String get savedPosts => 'Gespeicherte Beiträge';

  @override
  String get postSaved => 'Beitrag gespeichert';

  @override
  String get postSavedMessage =>
      'Sie können gespeicherte Beiträge auf der Meine Seite anzeigen';

  @override
  String get noMapAppAvailable => 'Keine Karten-App verfügbar';

  @override
  String get notificationLunchTitle =>
      '#Hast du heute schon dein Essen gepostet? 🍜';

  @override
  String get notificationLunchBody =>
      'Warum nicht das heutige Mittagessen aufzeichnen, solange du dich daran erinnerst?';

  @override
  String get notificationDinnerTitle =>
      '#Hast du heute schon dein Essen gepostet? 🍛';

  @override
  String get notificationDinnerBody =>
      'Poste das heutige Essen und beende den Tag sanft 📷';

  @override
  String get posted => 'veröffentlicht';

  @override
  String get tutorialLocationTitle => 'Standort aktivieren!';

  @override
  String get tutorialLocationSubTitle =>
      'Großartige Orte in der Nähe finden.\nRestaurantsuche vereinfachen.';

  @override
  String get tutorialLocationButton => 'Standort aktivieren';

  @override
  String get tutorialNotificationTitle => 'Benachrichtigungen aktivieren!';

  @override
  String get tutorialNotificationSubTitle =>
      'Erinnerungen für Mittag- und Abendessen';

  @override
  String get tutorialNotificationButton => 'Aktivieren';

  @override
  String get selectMapApp => 'Karten-App auswählen';

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
  String get streakDialogFirstTitle => 'Beitrag abgeschlossen';

  @override
  String get streakDialogFirstContent => 'Weiter posten\nfür Serie';

  @override
  String get streakDialogContinueTitle => 'Beitrag abgeschlossen';

  @override
  String streakDialogContinueContent(int weeks) {
    return '$weeks Wochen Serie!\nWeiter posten\nfür Serie';
  }

  @override
  String get translatableTranslate => 'Übersetzen';

  @override
  String get translatableShowOriginal => 'Original anzeigen';

  @override
  String get translatableCopy => 'Kopieren';

  @override
  String get translatableCopied => 'In Zwischenablage kopiert';

  @override
  String get translatableTranslateFailed => 'Übersetzung fehlgeschlagen';
}
