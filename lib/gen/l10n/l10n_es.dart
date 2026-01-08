// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get maybeNotFoodDialogTitle => 'Una pequeña confirmación 🍽️';

  @override
  String get maybeNotFoodDialogText =>
      'Esta foto podría no ser comida… 🤔\\n\\n¿Quieres publicarla de todos modos?';

  @override
  String get maybeNotFoodDialogConfirm => 'Continuar';

  @override
  String get maybeNotFoodDialogDelete => 'Eliminar imagen';

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get editTitle => 'Editar';

  @override
  String get editPostButton => 'Editar Publicación';

  @override
  String get emailInputField => 'Ingrese su dirección de correo electrónico';

  @override
  String get settingIcon => 'Seleccionar Icono';

  @override
  String get userName => 'Nombre de Usuario';

  @override
  String get userNameInputField => 'Nombre de usuario (ej: iseryu)';

  @override
  String get userId => 'ID de Usuario';

  @override
  String get userIdInputField => 'ID de usuario (ej: iseryuuu)';

  @override
  String get registerButton => 'Registrar';

  @override
  String get settingAppBar => 'Configuración';

  @override
  String get settingCheckVersion => 'Actualizar';

  @override
  String get settingCheckVersionDialogTitle => 'Información de Actualización';

  @override
  String get settingCheckVersionDialogText1 =>
      'Hay una nueva versión disponible.';

  @override
  String get settingCheckVersionDialogText2 =>
      'Por favor actualice a la última versión.';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'Reseña';

  @override
  String get settingShareApp => 'Compartir';

  @override
  String get settingLicense => 'Licencia';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'Privacidad';

  @override
  String get settingTermsOfUse => 'Términos';

  @override
  String get settingContact => 'Contacto';

  @override
  String get settingTutorial => 'Tutorial';

  @override
  String get settingCredit => 'Créditos';

  @override
  String get unregistered => 'No Registrado';

  @override
  String get settingBatteryLevel => 'Nivel de Batería';

  @override
  String get settingDeviceInfo => 'Información del Dispositivo';

  @override
  String get settingIosVersion => 'Versión de iOS';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'Versión de la App';

  @override
  String get settingAccount => 'Cuenta';

  @override
  String get settingLogoutButton => 'Cerrar Sesión';

  @override
  String get settingDeleteAccountButton => 'Borrar cuenta';

  @override
  String get settingQuestion => 'Preguntas';

  @override
  String get settingAccountManagement => 'Gestión de Cuenta';

  @override
  String get settingRestoreSuccessTitle => 'Restaurar';

  @override
  String get settingRestoreSuccessSubtitle => '¡Funciones premium habilitadas!';

  @override
  String get settingRestoreFailureTitle => 'Restauración fallida';

  @override
  String get settingRestoreFailureSubtitle =>
      '¿Sin historial de compras? Contacte soporte';

  @override
  String get settingRestore => 'Restaurar compra';

  @override
  String get settingPremiumMembership => 'Hazte miembro Premium';

  @override
  String get shareButton => 'Compartir';

  @override
  String get postFoodName => 'Nombre del Alimento';

  @override
  String get postFoodNameInputField => 'Qué comiste (obligatorio)';

  @override
  String get postRestaurantNameInputField => 'Restaurante (obligatorio)';

  @override
  String get postComment => 'Ingrese comentario (Opcional)';

  @override
  String get postCommentInputField => 'Comentario';

  @override
  String get postError => 'Error de envío';

  @override
  String get postCategoryTitle => 'País / Cocina (opcional)';

  @override
  String get postCountryCategory => 'País';

  @override
  String get postCuisineCategory => 'Cocina';

  @override
  String get postTitle => 'Publicar';

  @override
  String get postMissingInfo =>
      'Por favor complete todos los campos requeridos';

  @override
  String get postMissingPhoto => 'Por favor agregue una foto';

  @override
  String get postMissingFoodName => 'Por favor ingrese qué comió';

  @override
  String get postMissingRestaurant =>
      'Por favor agregue nombre del restaurante';

  @override
  String get postPhotoSuccess => 'Foto agregada exitosamente';

  @override
  String get postCameraPermission => 'Se requiere permiso de cámara';

  @override
  String get postAlbumPermission =>
      'Se requiere permiso de biblioteca de fotos';

  @override
  String get postSuccess => 'Publicación exitosa';

  @override
  String get postSearchError => 'No se puede buscar nombres de lugares';

  @override
  String get editUpdateButton => 'Actualizar';

  @override
  String get editBio => 'Biografía (opcional)';

  @override
  String get editBioInputField => 'Ingrese biografía';

  @override
  String get editFavoriteTagTitle => 'Seleccionar Etiqueta Favorita';

  @override
  String get emptyPosts => 'No hay publicaciones';

  @override
  String get searchEmptyResult =>
      'No se encontraron resultados para su búsqueda.';

  @override
  String get searchButton => 'Buscar';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchRestaurantTitle => 'Buscar Restaurantes';

  @override
  String get searchUserTitle => 'Búsqueda de Usuarios';

  @override
  String get searchUserHeader => 'Usuarios (por posts)';

  @override
  String searchUserPostCount(Object count) {
    return 'Publicaciones: $count';
  }

  @override
  String get searchUserLatestPosts => 'Últimas Publicaciones';

  @override
  String get searchUserNoUsers =>
      'No se encontraron usuarios con publicaciones';

  @override
  String get unknown => 'Desconocido・Sin resultados';

  @override
  String get profilePostCount => 'Publicaciones';

  @override
  String get profilePointCount => 'Puntos';

  @override
  String get profileEditButton => 'Editar Perfil';

  @override
  String get profileExchangePointsButton => 'Canjear Puntos';

  @override
  String get profileFavoriteGenre => 'Género Favorito';

  @override
  String get likeButton => 'Me Gusta';

  @override
  String get shareReviewPrefix =>
      '¡Acabo de compartir mi reseña de lo que comí!';

  @override
  String get shareReviewSuffix => '¡Para más, echa un vistazo a foodGram!';

  @override
  String get postDetailSheetTitle => 'Acerca de esta publicación';

  @override
  String get postDetailSheetShareButton => 'Compartir esta publicación';

  @override
  String get postDetailSheetReportButton => 'Reportar esta publicación';

  @override
  String get postDetailSheetBlockButton => 'Bloquear este usuario';

  @override
  String get dialogYesButton => 'Sí';

  @override
  String get dialogNoButton => 'No';

  @override
  String get dialogReportTitle => 'Reportar una Publicación';

  @override
  String get dialogReportDescription1 => 'Reportará esta publicación.';

  @override
  String get dialogReportDescription2 =>
      'Será dirigido a un Formulario de Google.';

  @override
  String get dialogBlockTitle => 'Confirmación de Bloqueo';

  @override
  String get dialogBlockDescription1 => '¿Quiere bloquear a este usuario?';

  @override
  String get dialogBlockDescription2 =>
      'Esto ocultará las publicaciones del usuario.';

  @override
  String get dialogBlockDescription3 =>
      'Los usuarios bloqueados se guardarán localmente.';

  @override
  String get dialogDeleteTitle => 'Eliminar Publicación';

  @override
  String get heartLimitMessage =>
      'Has alcanzado el límite de 10 me gusta de hoy. Por favor, inténtalo de nuevo mañana.';

  @override
  String get dialogDeleteDescription1 => '¿Quiere eliminar esta publicación?';

  @override
  String get dialogDeleteDescription2 =>
      'Una vez eliminada, no se puede restaurar.';

  @override
  String get dialogDeleteError => 'Error de eliminación.';

  @override
  String get dialogLogoutTitle => 'Confirmar Cierre de Sesión';

  @override
  String get dialogLogoutDescription1 => '¿Le gustaría cerrar sesión?';

  @override
  String get dialogLogoutDescription2 =>
      'El estado de la cuenta se almacena en el servidor.';

  @override
  String get dialogLogoutButton => 'Cerrar Sesión';

  @override
  String get errorTitle => 'Error de Comunicación';

  @override
  String get errorDescription1 => 'Ha ocurrido un error de conexión.';

  @override
  String get errorDescription2 =>
      'Verifique su conexión de red e intente de nuevo.';

  @override
  String get errorRefreshButton => 'Recargar';

  @override
  String get error => 'Han ocurrido errores';

  @override
  String get mapLoadingError => 'Ha ocurrido un error';

  @override
  String get mapLoadingRestaurant =>
      'Obteniendo información del restaurante...';

  @override
  String get appShareTitle => 'Compartir';

  @override
  String get appShareStoreButton => 'Compartir esta tienda';

  @override
  String get appShareInstagramButton => 'Compartir en Instagram';

  @override
  String get appShareGoButton => 'Ir a esta tienda';

  @override
  String get appShareCloseButton => 'Cerrar';

  @override
  String get shareInviteMessage => '¡Comparte comida deliciosa en FoodGram!';

  @override
  String get appRestaurantLabel => 'Buscar Restaurante';

  @override
  String get appRequestTitle => '🙇 Active la ubicación actual 🙇';

  @override
  String get appRequestReason =>
      'Se requieren datos de ubicación actual para la selección de restaurantes';

  @override
  String get appRequestInduction =>
      'Los siguientes botones lo llevarán a la pantalla de configuración';

  @override
  String get appRequestOpenSetting => 'Abrir pantalla de configuración';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'Comer × Foto × Compartir';

  @override
  String get agreeToTheTermsOfUse => 'Por favor acepte los Términos de Uso';

  @override
  String get restaurantCategoryList => 'Seleccionar Cocina por País';

  @override
  String get cookingCategoryList => 'Seleccionar etiqueta de comida';

  @override
  String get restaurantReviewNew => 'Nuevo';

  @override
  String get restaurantReviewViewDetails => 'Ver Detalles';

  @override
  String get restaurantReviewOtherPosts => 'Otras Publicaciones';

  @override
  String get restaurantReviewReviewList => 'Lista de Reseñas';

  @override
  String get restaurantReviewError => 'Ha ocurrido un error';

  @override
  String get nearbyRestaurants => '📍Restaurantes Cercanos';

  @override
  String get seeMore => 'Ver Más';

  @override
  String get selectCountryTag => 'Seleccionar Etiqueta de País';

  @override
  String get selectFavoriteTag => 'Seleccionar Etiqueta Favorita';

  @override
  String get favoriteTagPlaceholder => 'Seleccione su etiqueta favorita';

  @override
  String get selectFoodTag => 'Seleccionar Etiqueta de Comida';

  @override
  String get tabHome => 'Comida';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabMyMap => 'Mi Mapa';

  @override
  String get tabSearch => 'Buscar';

  @override
  String get tabMyPage => 'Mi Página';

  @override
  String get tabSetting => 'Ajustes';

  @override
  String get mapStatsVisitedArea => 'Zonas';

  @override
  String get mapStatsPosts => 'Posts';

  @override
  String get mapStatsActivityDays => 'Días';

  @override
  String get dayUnit => 'días';

  @override
  String get mapStatsPrefectures => 'Prefecturas';

  @override
  String get mapStatsAchievementRate => 'Tasa';

  @override
  String get mapStatsVisitedCountries => 'Países';

  @override
  String get mapViewTypeRecord => 'Registro';

  @override
  String get mapViewTypeJapan => 'Japón';

  @override
  String get mapViewTypeWorld => 'Mundo';

  @override
  String get logoutFailure => 'Error de cierre de sesión';

  @override
  String get accountDeletionFailure => 'Error de eliminación de cuenta';

  @override
  String get appleLoginFailure => 'Inicio de sesión con Apple no disponible';

  @override
  String get emailAuthenticationFailure => 'Error de autenticación por correo';

  @override
  String get loginError => 'Error de Inicio de Sesión';

  @override
  String get loginSuccessful => 'Inicio de sesión exitoso';

  @override
  String get emailAuthentication =>
      'Autentíquese con su aplicación de correo electrónico';

  @override
  String get emailEmpty => 'No se ha ingresado dirección de correo electrónico';

  @override
  String get email => 'Dirección de Correo Electrónico';

  @override
  String get enterTheCorrectFormat => 'Por favor ingrese el formato correcto';

  @override
  String get authInvalidFormat =>
      'El formato de la dirección de correo electrónico es incorrecto.';

  @override
  String get authSocketException =>
      'Hay un problema con la red. Por favor verifique la conexión.';

  @override
  String get camera => 'Cámara';

  @override
  String get album => 'Álbum';

  @override
  String get snsLogin => 'Inicio de sesión SNS';

  @override
  String get tutorialFirstPageTitle => 'Comparte tus momentos deliciosos';

  @override
  String get tutorialFirstPageSubTitle =>
      'Con FoodGram, haz que cada comida sea más especial.\n¡Disfruta descubriendo nuevos sabores!';

  @override
  String get tutorialDiscoverTitle => '¡Encuentra tu próximo plato favorito!';

  @override
  String get tutorialDiscoverSubTitle =>
      'Con cada desplazamiento, nuevos hallazgos deliciosos.\nExplora comida deliciosa ahora.';

  @override
  String get tutorialSecondPageTitle =>
      'Un mapa de comida único para esta aplicación';

  @override
  String get tutorialSecondPageSubTitle =>
      'Creemos un mapa único para esta aplicación.\nTus publicaciones ayudarán a evolucionar el mapa.';

  @override
  String get tutorialThirdPageTitle => 'Términos de Uso';

  @override
  String get tutorialThirdPageSubTitle =>
      '・Tenga cuidado al compartir información personal como nombre, dirección, número de teléfono o ubicación.\n\n・Evite publicar contenido ofensivo, inapropiado o dañino, y no use obras de otros sin permiso.\n\n・Las publicaciones no relacionadas con comida pueden ser eliminadas.\n\n・Los usuarios que violen repetidamente las reglas o publiquen contenido objetable pueden ser eliminados por el equipo de gestión.\n\n・Esperamos mejorar esta aplicación junto con todos. por los desarrolladores';

  @override
  String get tutorialThirdPageButton => 'Aceptar los términos de uso';

  @override
  String get tutorialThirdPageClose => 'Cerrar';

  @override
  String get detailMenuShare => 'Compartir';

  @override
  String get detailMenuVisit => 'Visitar';

  @override
  String get detailMenuPost => 'Publicar';

  @override
  String get detailMenuSearch => 'Buscar';

  @override
  String get forceUpdateTitle => 'Notificación de Actualización';

  @override
  String get forceUpdateText =>
      'Se ha lanzado una nueva versión de esta aplicación. Por favor actualice la aplicación para asegurar las últimas funciones y un entorno seguro.';

  @override
  String get forceUpdateButtonTitle => 'Actualizar';

  @override
  String get newAccountImportantTitle => 'Nota Importante';

  @override
  String get newAccountImportant =>
      'Al crear una cuenta, por favor no incluya información personal como dirección de correo electrónico o número de teléfono en su nombre de usuario o ID de usuario. Para asegurar una experiencia en línea segura, elija un nombre que no revele sus detalles personales.';

  @override
  String get accountRegistrationSuccess => 'Registro de cuenta completado';

  @override
  String get accountRegistrationError => 'Ha ocurrido un error';

  @override
  String get requiredInfoMissing => 'Falta información requerida';

  @override
  String get shareTextAndImage => 'Compartir con texto e imagen';

  @override
  String get shareImageOnly => 'Compartir solo imagen';

  @override
  String get foodCategoryNoodles => 'Fideos';

  @override
  String get foodCategoryMeat => 'Carne';

  @override
  String get foodCategoryFastFood => 'Comida Rápida';

  @override
  String get foodCategoryRiceDishes => 'Platos de Arroz';

  @override
  String get foodCategorySeafood => 'Mariscos';

  @override
  String get foodCategoryBread => 'Pan';

  @override
  String get foodCategorySweetsAndSnacks => 'Dulces y Snacks';

  @override
  String get foodCategoryFruits => 'Frutas';

  @override
  String get foodCategoryVegetables => 'Verduras';

  @override
  String get foodCategoryBeverages => 'Bebidas';

  @override
  String get foodCategoryOthers => 'Otros';

  @override
  String get foodCategoryAll => 'TODO';

  @override
  String get rankEmerald => 'Esmeralda';

  @override
  String get rankDiamond => 'Diamante';

  @override
  String get rankGold => 'Oro';

  @override
  String get rankSilver => 'Plata';

  @override
  String get rankBronze => 'Bronce';

  @override
  String get rank => 'Rango';

  @override
  String get promoteDialogTitle => '✨Conviértete en Miembro Premium✨';

  @override
  String get promoteDialogTrophyTitle => 'Función de Trofeos';

  @override
  String get promoteDialogTrophyDesc =>
      'Muestra trofeos basados en tus actividades.';

  @override
  String get promoteDialogTagTitle => 'Etiquetas Personalizadas';

  @override
  String get promoteDialogTagDesc =>
      'Establece etiquetas personalizadas para tus comidas favoritas.';

  @override
  String get promoteDialogIconTitle => 'Icono Personalizado';

  @override
  String get promoteDialogIconDesc =>
      '¡¡Establece tu icono de perfil a cualquier imagen que te guste!!';

  @override
  String get promoteDialogAdTitle => 'Sin Anuncios';

  @override
  String get promoteDialogAdDesc => '¡¡Elimina todos los anuncios!!';

  @override
  String get promoteDialogButton => 'Convertirse en Premium';

  @override
  String get promoteDialogLater => 'Tal Vez Después';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ Beneficios Premium ✨';

  @override
  String get paywallTrophyTitle => 'Consigue títulos al publicar más';

  @override
  String get paywallTrophyDesc => 'Los títulos suben según tus publicaciones';

  @override
  String get paywallTagTitle => 'Configura tus géneros favoritos';

  @override
  String get paywallTagDesc => 'Personaliza más tu perfil';

  @override
  String get paywallIconTitle => 'Usa cualquier imagen como icono';

  @override
  String get paywallIconDesc => 'Destaca entre otros creadores';

  @override
  String get paywallAdTitle => 'Sin Anuncios';

  @override
  String get paywallAdDesc => 'Elimina todos los anuncios';

  @override
  String get paywallComingSoon => 'Próximamente...';

  @override
  String get paywallNewFeatures =>
      '¡Nuevas funciones exclusivas premium\npróximamente!';

  @override
  String get paywallSubscribeButton => 'Convertirse en Miembro Premium';

  @override
  String get paywallPrice => 'mensual \$3 / mes';

  @override
  String get paywallCancelNote => 'Cancelar en cualquier momento';

  @override
  String get paywallWelcomeTitle => '¡Bienvenido a\nFoodGram Members!';

  @override
  String get paywallSkip => 'Saltar';

  @override
  String get purchaseError => 'Ha ocurrido un error durante la compra';

  @override
  String get paywallTagline => '✨ Mejora tu experiencia culinaria ✨';

  @override
  String get paywallMapTitle => 'Buscar con mapa';

  @override
  String get paywallMapDesc => 'Encuentra restaurantes más fácil y rápido';

  @override
  String get paywallRankTitle => 'Consigue títulos al publicar más';

  @override
  String get paywallRankDesc => 'Los títulos suben según tus publicaciones';

  @override
  String get paywallGenreTitle => 'Configura tus géneros favoritos';

  @override
  String get paywallGenreDesc => 'Personaliza más tu perfil';

  @override
  String get paywallCustomIconTitle => 'Usa cualquier imagen como icono';

  @override
  String get paywallCustomIconDesc => 'Destaca entre otros creadores';

  @override
  String get anonymousPost => 'Publicar Anónimamente';

  @override
  String get anonymousPostDescription => 'El nombre de usuario estará oculto';

  @override
  String get anonymousShare => 'Compartir Anónimamente';

  @override
  String get anonymousUpdate => 'Actualizar Anónimamente';

  @override
  String get anonymousPoster => 'Publicador Anónimo';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'Otra Cocina';

  @override
  String get tagOtherFood => 'Otra Comida';

  @override
  String get tagJapaneseCuisine => 'Cocina Japonesa';

  @override
  String get tagItalianCuisine => 'Cocina Italiana';

  @override
  String get tagFrenchCuisine => 'Cocina Francesa';

  @override
  String get tagChineseCuisine => 'Cocina China';

  @override
  String get tagIndianCuisine => 'Cocina India';

  @override
  String get tagMexicanCuisine => 'Cocina Mexicana';

  @override
  String get tagHongKongCuisine => 'Cocina de Hong Kong';

  @override
  String get tagAmericanCuisine => 'Cocina Americana';

  @override
  String get tagMediterraneanCuisine => 'Cocina Mediterránea';

  @override
  String get tagThaiCuisine => 'Cocina Tailandesa';

  @override
  String get tagGreekCuisine => 'Cocina Griega';

  @override
  String get tagTurkishCuisine => 'Cocina Turca';

  @override
  String get tagKoreanCuisine => 'Cocina Coreana';

  @override
  String get tagRussianCuisine => 'Cocina Rusa';

  @override
  String get tagSpanishCuisine => 'Cocina Española';

  @override
  String get tagVietnameseCuisine => 'Cocina Vietnamita';

  @override
  String get tagPortugueseCuisine => 'Cocina Portuguesa';

  @override
  String get tagAustrianCuisine => 'Cocina Austriaca';

  @override
  String get tagBelgianCuisine => 'Cocina Belga';

  @override
  String get tagSwedishCuisine => 'Cocina Sueca';

  @override
  String get tagGermanCuisine => 'Cocina Alemana';

  @override
  String get tagBritishCuisine => 'Cocina Británica';

  @override
  String get tagDutchCuisine => 'Cocina Holandesa';

  @override
  String get tagAustralianCuisine => 'Cocina Australiana';

  @override
  String get tagBrazilianCuisine => 'Cocina Brasileña';

  @override
  String get tagArgentineCuisine => 'Cocina Argentina';

  @override
  String get tagColombianCuisine => 'Cocina Colombiana';

  @override
  String get tagPeruvianCuisine => 'Cocina Peruana';

  @override
  String get tagNorwegianCuisine => 'Cocina Noruega';

  @override
  String get tagDanishCuisine => 'Cocina Danesa';

  @override
  String get tagPolishCuisine => 'Cocina Polaca';

  @override
  String get tagCzechCuisine => 'Cocina Checa';

  @override
  String get tagHungarianCuisine => 'Cocina Húngara';

  @override
  String get tagSouthAfricanCuisine => 'Cocina Sudafricana';

  @override
  String get tagEgyptianCuisine => 'Cocina Egipcia';

  @override
  String get tagMoroccanCuisine => 'Cocina Marroquí';

  @override
  String get tagNewZealandCuisine => 'Cocina Neozelandesa';

  @override
  String get tagFilipinoCuisine => 'Cocina Filipina';

  @override
  String get tagMalaysianCuisine => 'Cocina Malaya';

  @override
  String get tagSingaporeanCuisine => 'Cocina Singapurense';

  @override
  String get tagIndonesianCuisine => 'Cocina Indonesia';

  @override
  String get tagIranianCuisine => 'Cocina Iraní';

  @override
  String get tagSaudiArabianCuisine => 'Cocina Saudita';

  @override
  String get tagMongolianCuisine => 'Cocina Mongola';

  @override
  String get tagCambodianCuisine => 'Cocina Camboyana';

  @override
  String get tagLaotianCuisine => 'Cocina Laosiana';

  @override
  String get tagCubanCuisine => 'Cocina Cubana';

  @override
  String get tagJamaicanCuisine => 'Cocina Jamaiquina';

  @override
  String get tagChileanCuisine => 'Cocina Chilena';

  @override
  String get tagVenezuelanCuisine => 'Cocina Venezolana';

  @override
  String get tagPanamanianCuisine => 'Cocina Panameña';

  @override
  String get tagBolivianCuisine => 'Cocina Boliviana';

  @override
  String get tagIcelandicCuisine => 'Cocina Islandesa';

  @override
  String get tagLithuanianCuisine => 'Cocina Lituana';

  @override
  String get tagEstonianCuisine => 'Cocina Estonia';

  @override
  String get tagLatvianCuisine => 'Cocina Letona';

  @override
  String get tagFinnishCuisine => 'Cocina Finlandesa';

  @override
  String get tagCroatianCuisine => 'Cocina Croata';

  @override
  String get tagSlovenianCuisine => 'Cocina Eslovena';

  @override
  String get tagSlovakCuisine => 'Cocina Eslovaca';

  @override
  String get tagRomanianCuisine => 'Cocina Rumana';

  @override
  String get tagBulgarianCuisine => 'Cocina Búlgara';

  @override
  String get tagSerbianCuisine => 'Cocina Serbia';

  @override
  String get tagAlbanianCuisine => 'Cocina Albanesa';

  @override
  String get tagGeorgianCuisine => 'Cocina Georgiana';

  @override
  String get tagArmenianCuisine => 'Cocina Armenia';

  @override
  String get tagAzerbaijaniCuisine => 'Cocina Azerbaiyana';

  @override
  String get tagUkrainianCuisine => 'Cocina Ucraniana';

  @override
  String get tagBelarusianCuisine => 'Cocina Bielorrusa';

  @override
  String get tagKazakhCuisine => 'Cocina Kazaja';

  @override
  String get tagUzbekCuisine => 'Cocina Uzbeka';

  @override
  String get tagKyrgyzCuisine => 'Cocina Kirguisa';

  @override
  String get tagTurkmenCuisine => 'Cocina Turcomana';

  @override
  String get tagTajikCuisine => 'Cocina Tayika';

  @override
  String get tagMaldivianCuisine => 'Cocina Maldiva';

  @override
  String get tagNepaleseCuisine => 'Cocina Nepalí';

  @override
  String get tagBangladeshiCuisine => 'Cocina Bangladesí';

  @override
  String get tagMyanmarCuisine => 'Cocina Birmana';

  @override
  String get tagBruneianCuisine => 'Cocina Bruneana';

  @override
  String get tagTaiwaneseCuisine => 'Cocina Taiwanesa';

  @override
  String get tagNigerianCuisine => 'Cocina Nigeriana';

  @override
  String get tagKenyanCuisine => 'Cocina Keniana';

  @override
  String get tagGhanaianCuisine => 'Cocina Ghanesa';

  @override
  String get tagEthiopianCuisine => 'Cocina Etíope';

  @override
  String get tagSudaneseCuisine => 'Cocina Sudanesa';

  @override
  String get tagTunisianCuisine => 'Cocina Tunecina';

  @override
  String get tagAngolanCuisine => 'Cocina Angoleña';

  @override
  String get tagCongoleseCuisine => 'Cocina Congoleña';

  @override
  String get tagZimbabweanCuisine => 'Cocina Zimbabuense';

  @override
  String get tagMalagasyCuisine => 'Cocina Malgache';

  @override
  String get tagPapuaNewGuineanCuisine => 'Cocina Papú';

  @override
  String get tagSamoanCuisine => 'Cocina Samoana';

  @override
  String get tagTuvaluanCuisine => 'Cocina Tuvaluana';

  @override
  String get tagFijianCuisine => 'Cocina Fiyiana';

  @override
  String get tagPalauanCuisine => 'Cocina Palauana';

  @override
  String get tagKiribatiCuisine => 'Cocina Kiribatiana';

  @override
  String get tagVanuatuanCuisine => 'Cocina Vanuatuana';

  @override
  String get tagBahrainiCuisine => 'Cocina Bahreiní';

  @override
  String get tagQatariCuisine => 'Cocina Catarí';

  @override
  String get tagKuwaitiCuisine => 'Cocina Kuwaití';

  @override
  String get tagOmaniCuisine => 'Cocina Omaní';

  @override
  String get tagYemeniCuisine => 'Cocina Yemení';

  @override
  String get tagLebaneseCuisine => 'Cocina Libanesa';

  @override
  String get tagSyrianCuisine => 'Cocina Siria';

  @override
  String get tagJordanianCuisine => 'Cocina Jordana';

  @override
  String get tagNoodles => 'Fideos';

  @override
  String get tagMeatDishes => 'Platos de Carne';

  @override
  String get tagFastFood => 'Comida Rápida';

  @override
  String get tagRiceDishes => 'Platos de Arroz';

  @override
  String get tagSeafood => 'Mariscos';

  @override
  String get tagBread => 'Pan';

  @override
  String get tagSweetsAndSnacks => 'Dulces y Snacks';

  @override
  String get tagFruits => 'Frutas';

  @override
  String get tagVegetables => 'Verduras';

  @override
  String get tagBeverages => 'Bebidas';

  @override
  String get tagOthers => 'Otros';

  @override
  String get tagPasta => 'Pasta';

  @override
  String get tagRamen => 'Ramen';

  @override
  String get tagSteak => 'Bistec';

  @override
  String get tagYakiniku => 'Yakiniku';

  @override
  String get tagChicken => 'Pollo';

  @override
  String get tagBacon => 'Tocino';

  @override
  String get tagHamburger => 'Hamburguesa';

  @override
  String get tagFrenchFries => 'Papas Fritas';

  @override
  String get tagPizza => 'Pizza';

  @override
  String get tagTacos => 'Tacos';

  @override
  String get tagTamales => 'Tamales';

  @override
  String get tagGyoza => 'Gyoza';

  @override
  String get tagFriedShrimp => 'Camarón Frito';

  @override
  String get tagHotPot => 'Olla Caliente';

  @override
  String get tagCurry => 'Curry';

  @override
  String get tagPaella => 'Paella';

  @override
  String get tagFondue => 'Fondue';

  @override
  String get tagOnigiri => 'Onigiri';

  @override
  String get tagRice => 'Arroz';

  @override
  String get tagBento => 'Bento';

  @override
  String get tagSushi => 'Sushi';

  @override
  String get tagFish => 'Pescado';

  @override
  String get tagOctopus => 'Pulpo';

  @override
  String get tagSquid => 'Calamar';

  @override
  String get tagShrimp => 'Camarón';

  @override
  String get tagCrab => 'Cangrejo';

  @override
  String get tagShellfish => 'Mariscos';

  @override
  String get tagOyster => 'Ostra';

  @override
  String get tagSandwich => 'Sándwich';

  @override
  String get tagHotDog => 'Perro Caliente';

  @override
  String get tagDonut => 'Donut';

  @override
  String get tagPancake => 'Panqueque';

  @override
  String get tagCroissant => 'Croissant';

  @override
  String get tagBagel => 'Bagel';

  @override
  String get tagBaguette => 'Baguette';

  @override
  String get tagPretzel => 'Pretzel';

  @override
  String get tagBurrito => 'Burrito';

  @override
  String get tagIceCream => 'Helado';

  @override
  String get tagPudding => 'Pudín';

  @override
  String get tagRiceCracker => 'Galleta de Arroz';

  @override
  String get tagDango => 'Dango';

  @override
  String get tagShavedIce => 'Hielo Raspado';

  @override
  String get tagPie => 'Pastel';

  @override
  String get tagCupcake => 'Cupcake';

  @override
  String get tagCake => 'Pastel';

  @override
  String get tagCandy => 'Caramelo';

  @override
  String get tagLollipop => 'Paleta';

  @override
  String get tagChocolate => 'Chocolate';

  @override
  String get tagPopcorn => 'Palomitas';

  @override
  String get tagCookie => 'Galleta';

  @override
  String get tagPeanuts => 'Maní';

  @override
  String get tagBeans => 'Frijoles';

  @override
  String get tagChestnut => 'Castaña';

  @override
  String get tagFortuneCookie => 'Galleta de la Fortuna';

  @override
  String get tagMooncake => 'Pastel de Luna';

  @override
  String get tagHoney => 'Miel';

  @override
  String get tagWaffle => 'Waffle';

  @override
  String get tagApple => 'Manzana';

  @override
  String get tagPear => 'Pera';

  @override
  String get tagOrange => 'Naranja';

  @override
  String get tagLemon => 'Limón';

  @override
  String get tagLime => 'Lima';

  @override
  String get tagBanana => 'Plátano';

  @override
  String get tagWatermelon => 'Sandía';

  @override
  String get tagGrapes => 'Uvas';

  @override
  String get tagStrawberry => 'Fresa';

  @override
  String get tagBlueberry => 'Arándano';

  @override
  String get tagMelon => 'Melón';

  @override
  String get tagCherry => 'Cereza';

  @override
  String get tagPeach => 'Durazno';

  @override
  String get tagMango => 'Mango';

  @override
  String get tagPineapple => 'Piña';

  @override
  String get tagCoconut => 'Coco';

  @override
  String get tagKiwi => 'Kiwi';

  @override
  String get tagSalad => 'Ensalada';

  @override
  String get tagTomato => 'Tomate';

  @override
  String get tagEggplant => 'Berenjena';

  @override
  String get tagAvocado => 'Aguacate';

  @override
  String get tagGreenBeans => 'Ejotes';

  @override
  String get tagBroccoli => 'Brócoli';

  @override
  String get tagLettuce => 'Lechuga';

  @override
  String get tagCucumber => 'Pepino';

  @override
  String get tagChili => 'Chile';

  @override
  String get tagBellPepper => 'Pimiento';

  @override
  String get tagCorn => 'Maíz';

  @override
  String get tagCarrot => 'Zanahoria';

  @override
  String get tagOlive => 'Aceituna';

  @override
  String get tagGarlic => 'Ajo';

  @override
  String get tagOnion => 'Cebolla';

  @override
  String get tagPotato => 'Papa';

  @override
  String get tagSweetPotato => 'Camote';

  @override
  String get tagGinger => 'Jengibre';

  @override
  String get tagShiitake => 'Shiitake';

  @override
  String get tagTeapot => 'Tetera';

  @override
  String get tagCoffee => 'Café';

  @override
  String get tagTea => 'Té';

  @override
  String get tagJuice => 'Jugo';

  @override
  String get tagSoftDrink => 'Refresco';

  @override
  String get tagBubbleTea => 'Té de Burbujas';

  @override
  String get tagSake => 'Sake';

  @override
  String get tagBeer => 'Cerveza';

  @override
  String get tagChampagne => 'Champán';

  @override
  String get tagWine => 'Vino';

  @override
  String get tagWhiskey => 'Whisky';

  @override
  String get tagCocktail => 'Cóctel';

  @override
  String get tagTropicalCocktail => 'Cóctel Tropical';

  @override
  String get tagMateTea => 'Té de Mate';

  @override
  String get tagMilk => 'Leche';

  @override
  String get tagKamaboko => 'Kamaboko';

  @override
  String get tagOden => 'Oden';

  @override
  String get tagCheese => 'Queso';

  @override
  String get tagEgg => 'Huevo';

  @override
  String get tagFriedEgg => 'Huevo Frito';

  @override
  String get tagButter => 'Mantequilla';

  @override
  String get done => 'Hecho';

  @override
  String get save => 'Guardar';

  @override
  String get searchFood => 'Buscar comida';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get searchEmptyTitle => 'Ingrese nombre del restaurante para buscar';

  @override
  String get searchEmptyHintTitle => 'Consejos de búsqueda';

  @override
  String get searchEmptyHintLocation =>
      'Active la ubicación para mostrar resultados cercanos primero';

  @override
  String get searchEmptyHintSearch =>
      'Busque por nombre de restaurante o tipo de cocina';

  @override
  String get postErrorPickImage => 'Error al tomar foto';

  @override
  String get favoritePostEmptyTitle => 'No hay publicaciones guardadas';

  @override
  String get favoritePostEmptySubtitle =>
      '¡Guarda publicaciones que te interesen!';

  @override
  String get userInfoFetchError => 'Error al obtener información del usuario';

  @override
  String get saved => 'Guardado';

  @override
  String get savedPosts => 'Publicaciones guardadas';

  @override
  String get postSaved => 'Publicación guardada';

  @override
  String get postSavedMessage =>
      'Puedes ver las publicaciones guardadas en Mi página';

  @override
  String get noMapAppAvailable => 'No hay aplicación de mapas disponible';

  @override
  String get notificationLunchTitle => '#¿Ya publicaste la comida de hoy? 🍜';

  @override
  String get notificationLunchBody =>
      '¿Por qué no registras el almuerzo de hoy mientras lo recuerdas?';

  @override
  String get notificationDinnerTitle => '#¿Ya publicaste la comida de hoy? 🍛';

  @override
  String get notificationDinnerBody =>
      'Publica la comida de hoy y termina el día suavemente 📷';

  @override
  String get posted => 'publicado';

  @override
  String get tutorialLocationTitle => '¡Activa la ubicación!';

  @override
  String get tutorialLocationSubTitle =>
      'Para encontrar buenos lugares cercanos,\nfacilita el descubrimiento de restaurantes';

  @override
  String get tutorialLocationButton => 'Activar ubicación';

  @override
  String get tutorialNotificationTitle => '¡Activa las notificaciones!';

  @override
  String get tutorialNotificationSubTitle =>
      'Enviaremos recordatorios al almuerzo y la cena';

  @override
  String get tutorialNotificationButton => 'Activar notificaciones';

  @override
  String get selectMapApp => 'Seleccionar aplicación de mapas';

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
  String get streakDialogFirstTitle => 'Publicación completada';

  @override
  String get streakDialogFirstContent =>
      'Sigue publicando\npara mantener racha';

  @override
  String get streakDialogContinueTitle => 'Publicación completada';

  @override
  String streakDialogContinueContent(int weeks) {
    return '¡$weeks semanas seguidas!\nSigue publicando\npara mantener racha';
  }

  @override
  String get translatableTranslate => 'Traducir';

  @override
  String get translatableShowOriginal => 'Mostrar original';

  @override
  String get translatableCopy => 'Copiar';

  @override
  String get translatableCopied => 'Copiado al portapapeles';

  @override
  String get translatableTranslateFailed => 'Error al traducir';

  @override
  String get likeNotificationsTitle => 'Notificaciones de Me gusta';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get someoneLikedYourPost =>
      'Alguien indicó que le gusta tu publicación.';

  @override
  String userLikedYourPost(String name) {
    return '$name indicó que le gusta tu publicación.';
  }
}
