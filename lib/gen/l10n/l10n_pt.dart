// ignore_for_file

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get maybeNotFoodDialogTitle => 'Só conferindo 🍽️';

  @override
  String get maybeNotFoodDialogText =>
      'Esta foto pode não ser de comida… 🤔\\n\\nDeseja publicar mesmo assim?';

  @override
  String get maybeNotFoodDialogConfirm => 'Continuar';

  @override
  String get maybeNotFoodDialogDelete => 'Excluir imagem';

  @override
  String get close => 'Fechar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get editTitle => 'Editar';

  @override
  String get editPostButton => 'Editar Publicação';

  @override
  String get emailInputField => 'Digite seu endereço de e-mail';

  @override
  String get settingIcon => 'Selecionar Ícone';

  @override
  String get userName => 'Nome de Usuário';

  @override
  String get userNameInputField => 'Nome de usuário (ex: iseryu)';

  @override
  String get userId => 'ID do Usuário';

  @override
  String get userIdInputField => 'ID do usuário (ex: iseryuuu)';

  @override
  String get registerButton => 'Registrar';

  @override
  String get settingAppBar => 'Configurações';

  @override
  String get settingCheckVersion => 'Atualizar';

  @override
  String get settingCheckVersionDialogTitle => 'Informações de Atualização';

  @override
  String get settingCheckVersionDialogText1 =>
      'Uma nova versão está disponível.';

  @override
  String get settingCheckVersionDialogText2 =>
      'Por favor, atualize para a versão mais recente.';

  @override
  String get settingDeveloper => 'Twitter';

  @override
  String get settingGithub => 'Github';

  @override
  String get settingReview => 'Avaliar';

  @override
  String get settingShareApp => 'Compartilhar';

  @override
  String get settingLicense => 'Licença';

  @override
  String get settingFaq => 'FAQ';

  @override
  String get settingPrivacyPolicy => 'Privacidade';

  @override
  String get settingTermsOfUse => 'Termos de Uso';

  @override
  String get settingContact => 'Contato';

  @override
  String get settingTutorial => 'Tutorial';

  @override
  String get settingCredit => 'Créditos';

  @override
  String get unregistered => 'Não Registrado';

  @override
  String get settingBatteryLevel => 'Nível da Bateria';

  @override
  String get settingDeviceInfo => 'Informações do Dispositivo';

  @override
  String get settingIosVersion => 'Versão do iOS';

  @override
  String get settingAndroidSdk => 'SDK';

  @override
  String get settingAppVersion => 'Versão do App';

  @override
  String get settingAccount => 'Conta';

  @override
  String get settingLogoutButton => 'Sair';

  @override
  String get settingDeleteAccountButton => 'Excluir conta';

  @override
  String get settingQuestion => 'Caixa de Perguntas';

  @override
  String get settingAccountManagement => 'Gerenciamento de Conta';

  @override
  String get settingRestoreSuccessTitle => 'Restauração bem-sucedida';

  @override
  String get settingRestoreSuccessSubtitle => 'Recursos premium ativados!';

  @override
  String get settingRestoreFailureTitle => 'Falha na restauração';

  @override
  String get settingRestoreFailureSubtitle =>
      'Sem histórico de compras? Entre em contato com o suporte';

  @override
  String get settingRestore => 'Restaurar';

  @override
  String get settingPremiumMembership => 'Torne-se membro Premium';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String get postFoodName => 'Nome da Comida';

  @override
  String get postFoodNameInputField => 'Comida (Obrigatório)';

  @override
  String get postRestaurantNameInputField => 'Restaurante (Obrigatório)';

  @override
  String get postComment => 'Digite comentário (Opcional)';

  @override
  String get postCommentInputField => 'Comentário';

  @override
  String get postError => 'Falha no envio';

  @override
  String get postCategoryTitle => 'País/Cozinha (Opcional)';

  @override
  String get postCountryCategory => 'País';

  @override
  String get postCuisineCategory => 'Cozinha';

  @override
  String get postTitle => 'Publicar';

  @override
  String get postMissingInfo =>
      'Por favor, preencha todos os campos obrigatórios';

  @override
  String get postMissingPhoto => 'Por favor, adicione uma foto';

  @override
  String get postMissingFoodName => 'Por favor, digite o que você comeu';

  @override
  String get postMissingRestaurant =>
      'Por favor, adicione o nome do restaurante';

  @override
  String get postPhotoSuccess => 'Foto adicionada com sucesso';

  @override
  String get postCameraPermission => 'Permissão de câmera necessária';

  @override
  String get postAlbumPermission =>
      'Permissão de biblioteca de fotos necessária';

  @override
  String get postSuccess => 'Publicação bem-sucedida';

  @override
  String get postSearchError => 'Não é possível pesquisar nomes de lugares';

  @override
  String get editUpdateButton => 'Atualizar';

  @override
  String get editBio => 'Biografia (opcional)';

  @override
  String get editBioInputField => 'Digite a biografia';

  @override
  String get editFavoriteTagTitle => 'Selecionar Etiqueta Favorita';

  @override
  String get emptyPosts => 'Não há publicações';

  @override
  String get searchEmptyResult =>
      'Nenhum resultado encontrado para sua pesquisa.';

  @override
  String get searchButton => 'Pesquisar';

  @override
  String get searchTitle => 'Pesquisar';

  @override
  String get searchRestaurantTitle => 'Pesquisar Restaurantes';

  @override
  String get searchUserTitle => 'Pesquisa de Usuários';

  @override
  String get searchUserHeader => 'Pesquisa de Usuários (por posts)';

  @override
  String searchUserPostCount(Object count) {
    return 'Publicações: $count';
  }

  @override
  String get searchUserLatestPosts => 'Publicações Recentes';

  @override
  String get searchUserNoUsers => 'Nenhum usuário com publicações encontrado';

  @override
  String get unknown => 'Desconhecido・Sem resultados';

  @override
  String get profilePostCount => 'Publicações';

  @override
  String get profilePointCount => 'Pontos';

  @override
  String get profileEditButton => 'Editar Perfil';

  @override
  String get profileExchangePointsButton => 'Trocar Pontos';

  @override
  String get profileFavoriteGenre => 'Gênero Favorito';

  @override
  String get likeButton => 'Curtir';

  @override
  String get shareReviewPrefix =>
      'Acabei de compartilhar minha avaliação do que comi!';

  @override
  String get shareReviewSuffix => 'Para mais, dê uma olhada no foodGram!';

  @override
  String get postDetailSheetTitle => 'Sobre esta publicação';

  @override
  String get postDetailSheetShareButton => 'Compartilhar esta publicação';

  @override
  String get postDetailSheetReportButton => 'Denunciar esta publicação';

  @override
  String get postDetailSheetBlockButton => 'Bloquear este usuário';

  @override
  String get dialogYesButton => 'Sim';

  @override
  String get dialogNoButton => 'Não';

  @override
  String get dialogReportTitle => 'Denunciar uma Publicação';

  @override
  String get dialogReportDescription1 => 'Você denunciará esta publicação.';

  @override
  String get dialogReportDescription2 =>
      'Você será direcionado para um Formulário do Google.';

  @override
  String get dialogBlockTitle => 'Confirmar Bloqueio';

  @override
  String get dialogBlockDescription1 => 'Você quer bloquear este usuário?';

  @override
  String get dialogBlockDescription2 =>
      'Isso ocultará as publicações do usuário.';

  @override
  String get dialogBlockDescription3 =>
      'Usuários bloqueados serão salvos localmente.';

  @override
  String get dialogDeleteTitle => 'Excluir Publicação';

  @override
  String get heartLimitMessage =>
      'Você atingiu o limite de 10 curtidas de hoje. Por favor, tente novamente amanhã.';

  @override
  String get dialogDeleteDescription1 => 'Você quer excluir esta publicação?';

  @override
  String get dialogDeleteDescription2 =>
      'Uma vez excluída, não pode ser restaurada.';

  @override
  String get dialogDeleteError => 'Falha na exclusão.';

  @override
  String get dialogLogoutTitle => 'Confirmar Saída';

  @override
  String get dialogLogoutDescription1 => 'Você quer sair?';

  @override
  String get dialogLogoutDescription2 =>
      'O status da conta é armazenado no servidor.';

  @override
  String get dialogLogoutButton => 'Sair';

  @override
  String get errorTitle => 'Erro de Comunicação';

  @override
  String get errorDescription1 => 'Ocorreu um erro de conexão.';

  @override
  String get errorDescription2 =>
      'Verifique sua conexão de rede e tente novamente.';

  @override
  String get errorRefreshButton => 'Recarregar';

  @override
  String get error => 'Ocorreram erros';

  @override
  String get mapLoadingError => 'Ocorreu um erro';

  @override
  String get mapLoadingRestaurant => 'Obtendo informações do restaurante...';

  @override
  String get appShareTitle => 'Compartilhar';

  @override
  String get appShareStoreButton => 'Compartilhar esta loja';

  @override
  String get appShareInstagramButton => 'Compartilhar no Instagram';

  @override
  String get appShareGoButton => 'Ir para esta loja';

  @override
  String get appShareCloseButton => 'Fechar';

  @override
  String get shareInviteMessage => 'Compartilhe comida deliciosa no FoodGram!';

  @override
  String get appRestaurantLabel => 'Pesquisar Restaurante';

  @override
  String get appRequestTitle => '🙇 Ative a localização atual 🙇';

  @override
  String get appRequestReason =>
      'Dados de localização atual são necessários para seleção de restaurantes';

  @override
  String get appRequestInduction =>
      'Os seguintes botões o levarão à tela de configurações';

  @override
  String get appRequestOpenSetting => 'Abrir tela de configurações';

  @override
  String get appTitle => 'FoodGram';

  @override
  String get appSubtitle => 'Comer × Fotos × Compartilhar';

  @override
  String get agreeToTheTermsOfUse => 'Por favor, concorde com os Termos de Uso';

  @override
  String get restaurantCategoryList => 'Selecionar Cozinha por País';

  @override
  String get cookingCategoryList => 'Selecionar etiqueta de comida';

  @override
  String get restaurantReviewNew => 'Novo';

  @override
  String get restaurantReviewViewDetails => 'Ver Detalhes';

  @override
  String get restaurantReviewOtherPosts => 'Outras Publicações';

  @override
  String get restaurantReviewReviewList => 'Lista de Avaliações';

  @override
  String get restaurantReviewError => 'Ocorreu um erro';

  @override
  String get nearbyRestaurants => '📍Restaurantes Próximos';

  @override
  String get seeMore => 'Ver Mais';

  @override
  String get selectCountryTag => 'Selecionar Etiqueta de País';

  @override
  String get selectFavoriteTag => 'Selecionar Etiqueta Favorita';

  @override
  String get favoriteTagPlaceholder => 'Selecione sua etiqueta favorita';

  @override
  String get selectFoodTag => 'Selecionar Etiqueta de Comida';

  @override
  String get tabHome => 'Comida';

  @override
  String get tabMap => 'Mapa';

  @override
  String get tabMyMap => 'Meu Mapa';

  @override
  String get tabSearch => 'Pesquisar';

  @override
  String get tabMyPage => 'Minha Página';

  @override
  String get tabSetting => 'Ajustes';

  @override
  String get mapStatsVisitedArea => 'Áreas';

  @override
  String get mapStatsPosts => 'Posts';

  @override
  String get mapStatsActivityDays => 'Dias';

  @override
  String get dayUnit => 'dias';

  @override
  String get mapStatsPrefectures => 'Prefeituras';

  @override
  String get mapStatsAchievementRate => 'Taxa';

  @override
  String get mapStatsVisitedCountries => 'Países';

  @override
  String get mapViewTypeRecord => 'Registro';

  @override
  String get mapViewTypeJapan => 'Japão';

  @override
  String get mapViewTypeWorld => 'Mundo';

  @override
  String get logoutFailure => 'Falha no logout';

  @override
  String get accountDeletionFailure => 'Falha na exclusão da conta';

  @override
  String get appleLoginFailure => 'Login Apple não disponível';

  @override
  String get emailAuthenticationFailure => 'Falha na autenticação por e-mail';

  @override
  String get loginError => 'Erro de Login';

  @override
  String get loginSuccessful => 'Login bem-sucedido';

  @override
  String get emailAuthentication =>
      'Autentique-se com seu aplicativo de e-mail';

  @override
  String get emailEmpty => 'Nenhum endereço de e-mail foi inserido';

  @override
  String get email => 'Endereço de E-mail';

  @override
  String get enterTheCorrectFormat => 'Por favor, digite o formato correto';

  @override
  String get authInvalidFormat =>
      'O formato do endereço de e-mail está incorreto.';

  @override
  String get authSocketException =>
      'Há um problema com a rede. Por favor, verifique a conexão.';

  @override
  String get camera => 'Câmera';

  @override
  String get album => 'Álbum';

  @override
  String get snsLogin => 'Login SNS';

  @override
  String get tutorialFirstPageTitle => 'Momentos deliciosos';

  @override
  String get tutorialFirstPageSubTitle =>
      'Cada refeição mais especial.\nDescubra novos sabores!';

  @override
  String get tutorialDiscoverTitle => 'Seu próximo prato favorito!';

  @override
  String get tutorialDiscoverSubTitle =>
      'Novas descobertas a cada rolagem.\nExplore comidas deliciosas.';

  @override
  String get tutorialSecondPageTitle => 'Mapa de comida único';

  @override
  String get tutorialSecondPageSubTitle =>
      'Crie um mapa único.\nSuas publicações evoluem o mapa.';

  @override
  String get tutorialThirdPageTitle => 'Termos de Uso';

  @override
  String get tutorialThirdPageSubTitle =>
      '・Tenha cuidado ao compartilhar informações pessoais como nome, endereço, número de telefone ou localização.\n\n・Evite publicar conteúdo ofensivo, inadequado ou prejudicial, e não use obras de outros sem permissão.\n\n・Publicações não relacionadas à comida podem ser removidas.\n\n・Usuários que violam repetidamente as regras ou publicam conteúdo objetável podem ser removidos pela equipe de gerenciamento.\n\n・Esperamos melhorar este aplicativo junto com todos. pelos desenvolvedores';

  @override
  String get tutorialThirdPageButton => 'Aceitar';

  @override
  String get tutorialThirdPageClose => 'Fechar';

  @override
  String get detailMenuShare => 'Compartilhar';

  @override
  String get detailMenuVisit => 'Visitar';

  @override
  String get detailMenuPost => 'Publicar';

  @override
  String get detailMenuSearch => 'Pesquisar';

  @override
  String get forceUpdateTitle => 'Notificação de Atualização';

  @override
  String get forceUpdateText =>
      'Uma nova versão deste aplicativo foi lançada. Por favor, atualize o aplicativo para garantir os recursos mais recentes e um ambiente seguro.';

  @override
  String get forceUpdateButtonTitle => 'Atualizar';

  @override
  String get newAccountImportantTitle => 'Nota Importante';

  @override
  String get newAccountImportant =>
      'Ao criar uma conta, por favor não inclua informações pessoais como endereço de e-mail ou número de telefone em seu nome de usuário ou ID de usuário. Para garantir uma experiência online segura, escolha um nome que não revele seus detalhes pessoais.';

  @override
  String get accountRegistrationSuccess => 'Registro de conta concluído';

  @override
  String get accountRegistrationError => 'Ocorreu um erro';

  @override
  String get requiredInfoMissing => 'Informações obrigatórias em falta';

  @override
  String get shareTextAndImage => 'Texto e imagem';

  @override
  String get shareImageOnly => 'Compartilhar apenas imagem';

  @override
  String get foodCategoryNoodles => 'Macarrão';

  @override
  String get foodCategoryMeat => 'Carne';

  @override
  String get foodCategoryFastFood => 'Fast Food';

  @override
  String get foodCategoryRiceDishes => 'Pratos de Arroz';

  @override
  String get foodCategorySeafood => 'Frutos do Mar';

  @override
  String get foodCategoryBread => 'Pão';

  @override
  String get foodCategorySweetsAndSnacks => 'Doces e Lanches';

  @override
  String get foodCategoryFruits => 'Frutas';

  @override
  String get foodCategoryVegetables => 'Legumes';

  @override
  String get foodCategoryBeverages => 'Bebidas';

  @override
  String get foodCategoryOthers => 'Outros';

  @override
  String get foodCategoryAll => 'TODOS';

  @override
  String get rankEmerald => 'Esmeralda';

  @override
  String get rankDiamond => 'Diamante';

  @override
  String get rankGold => 'Ouro';

  @override
  String get rankSilver => 'Prata';

  @override
  String get rankBronze => 'Bronze';

  @override
  String get rank => 'Ranking';

  @override
  String get promoteDialogTitle => '✨Torne-se um Membro Premium✨';

  @override
  String get promoteDialogTrophyTitle => 'Função Troféu';

  @override
  String get promoteDialogTrophyDesc =>
      'Exibe troféus baseados em suas atividades.';

  @override
  String get promoteDialogTagTitle => 'Tags Personalizadas';

  @override
  String get promoteDialogTagDesc =>
      'Defina tags personalizadas para suas comidas favoritas.';

  @override
  String get promoteDialogIconTitle => 'Ícone Personalizado';

  @override
  String get promoteDialogIconDesc =>
      'Defina seu ícone de perfil para qualquer imagem que você goste !!';

  @override
  String get promoteDialogAdTitle => 'Sem Anúncios';

  @override
  String get promoteDialogAdDesc => 'Remove todos os anúncios !!';

  @override
  String get promoteDialogButton => 'Tornar-se Premium';

  @override
  String get promoteDialogLater => 'Talvez Depois';

  @override
  String get paywallTitle => 'FoodGram Premium';

  @override
  String get paywallPremiumTitle => '✨ Benefícios Premium ✨';

  @override
  String get paywallTrophyTitle => 'Ganhe títulos ao publicar mais';

  @override
  String get paywallTrophyDesc =>
      'Os títulos evoluem com a sua contagem de posts';

  @override
  String get paywallTagTitle => 'Defina seus gêneros favoritos';

  @override
  String get paywallTagDesc => 'Deixe o perfil mais estiloso';

  @override
  String get paywallIconTitle => 'Use qualquer imagem como ícone';

  @override
  String get paywallIconDesc => 'Destaque-se de outros criadores';

  @override
  String get paywallAdTitle => 'Sem Anúncios';

  @override
  String get paywallAdDesc => 'Remove todos os anúncios';

  @override
  String get paywallComingSoon => 'Em breve...';

  @override
  String get paywallNewFeatures =>
      'Novos recursos exclusivos premium\nchegando em breve!';

  @override
  String get paywallSubscribeButton => 'Tornar-se Membro Premium';

  @override
  String get paywallPrice => 'mensal \$3 / mês';

  @override
  String get paywallCancelNote => 'Cancele a qualquer momento';

  @override
  String get paywallWelcomeTitle => 'Bem-vindo ao\nFoodGram Members!';

  @override
  String get paywallSkip => 'Pular';

  @override
  String get purchaseError => 'Ocorreu um erro durante a compra';

  @override
  String get paywallTagline => '✨ Melhore sua experiência gastronômica ✨';

  @override
  String get paywallMapTitle => 'Buscar no mapa';

  @override
  String get paywallMapDesc => 'Encontre restaurantes de forma rápida e fácil';

  @override
  String get paywallRankTitle => 'Ganhe títulos ao publicar mais';

  @override
  String get paywallRankDesc => 'Os títulos evoluem com sua contagem de posts';

  @override
  String get paywallGenreTitle => 'Defina seus gêneros favoritos';

  @override
  String get paywallGenreDesc => 'Deixe o perfil mais estiloso';

  @override
  String get paywallCustomIconTitle => 'Use qualquer imagem como ícone';

  @override
  String get paywallCustomIconDesc => 'Destaque-se de outros criadores';

  @override
  String get anonymousPost => 'Publicar Anonimamente';

  @override
  String get anonymousPostDescription => 'Nome de usuário será ocultado';

  @override
  String get anonymousShare => 'Compartilhar Anonimamente';

  @override
  String get anonymousUpdate => 'Atualizar Anonimamente';

  @override
  String get anonymousPoster => 'Autor Anônimo';

  @override
  String get anonymousUsername => 'foodgramer';

  @override
  String get tagOtherCuisine => 'Outra Cozinha';

  @override
  String get tagOtherFood => 'Outra Comida';

  @override
  String get tagJapaneseCuisine => 'Cozinha Japonesa';

  @override
  String get tagItalianCuisine => 'Cozinha Italiana';

  @override
  String get tagFrenchCuisine => 'Cozinha Francesa';

  @override
  String get tagChineseCuisine => 'Cozinha Chinesa';

  @override
  String get tagIndianCuisine => 'Cozinha Indiana';

  @override
  String get tagMexicanCuisine => 'Cozinha Mexicana';

  @override
  String get tagHongKongCuisine => 'Cozinha de Hong Kong';

  @override
  String get tagAmericanCuisine => 'Cozinha Americana';

  @override
  String get tagMediterraneanCuisine => 'Cozinha Mediterrânea';

  @override
  String get tagThaiCuisine => 'Cozinha Tailandesa';

  @override
  String get tagGreekCuisine => 'Cozinha Grega';

  @override
  String get tagTurkishCuisine => 'Cozinha Turca';

  @override
  String get tagKoreanCuisine => 'Cozinha Coreana';

  @override
  String get tagRussianCuisine => 'Cozinha Russa';

  @override
  String get tagSpanishCuisine => 'Cozinha Espanhola';

  @override
  String get tagVietnameseCuisine => 'Cozinha Vietnamita';

  @override
  String get tagPortugueseCuisine => 'Cozinha Portuguesa';

  @override
  String get tagAustrianCuisine => 'Cozinha Austríaca';

  @override
  String get tagBelgianCuisine => 'Cozinha Belga';

  @override
  String get tagSwedishCuisine => 'Cozinha Sueca';

  @override
  String get tagGermanCuisine => 'Cozinha Alemã';

  @override
  String get tagBritishCuisine => 'Cozinha Britânica';

  @override
  String get tagDutchCuisine => 'Cozinha Holandesa';

  @override
  String get tagAustralianCuisine => 'Cozinha Australiana';

  @override
  String get tagBrazilianCuisine => 'Cozinha Brasileira';

  @override
  String get tagArgentineCuisine => 'Cozinha Argentina';

  @override
  String get tagColombianCuisine => 'Cozinha Colombiana';

  @override
  String get tagPeruvianCuisine => 'Cozinha Peruana';

  @override
  String get tagNorwegianCuisine => 'Cozinha Norueguesa';

  @override
  String get tagDanishCuisine => 'Cozinha Dinamarquesa';

  @override
  String get tagPolishCuisine => 'Cozinha Polonesa';

  @override
  String get tagCzechCuisine => 'Cozinha Tcheca';

  @override
  String get tagHungarianCuisine => 'Cozinha Húngara';

  @override
  String get tagSouthAfricanCuisine => 'Cozinha Sul-Africana';

  @override
  String get tagEgyptianCuisine => 'Cozinha Egípcia';

  @override
  String get tagMoroccanCuisine => 'Cozinha Marroquina';

  @override
  String get tagNewZealandCuisine => 'Cozinha Neozelandesa';

  @override
  String get tagFilipinoCuisine => 'Cozinha Filipina';

  @override
  String get tagMalaysianCuisine => 'Cozinha Malaia';

  @override
  String get tagSingaporeanCuisine => 'Cozinha de Cingapura';

  @override
  String get tagIndonesianCuisine => 'Cozinha Indonésia';

  @override
  String get tagIranianCuisine => 'Cozinha Iraniana';

  @override
  String get tagSaudiArabianCuisine => 'Cozinha Saudita';

  @override
  String get tagMongolianCuisine => 'Cozinha Mongol';

  @override
  String get tagCambodianCuisine => 'Cozinha Cambojana';

  @override
  String get tagLaotianCuisine => 'Cozinha Laosiana';

  @override
  String get tagCubanCuisine => 'Cozinha Cubana';

  @override
  String get tagJamaicanCuisine => 'Cozinha Jamaicana';

  @override
  String get tagChileanCuisine => 'Cozinha Chilena';

  @override
  String get tagVenezuelanCuisine => 'Cozinha Venezuelana';

  @override
  String get tagPanamanianCuisine => 'Cozinha Panamenha';

  @override
  String get tagBolivianCuisine => 'Cozinha Boliviana';

  @override
  String get tagIcelandicCuisine => 'Cozinha Islandesa';

  @override
  String get tagLithuanianCuisine => 'Cozinha Lituana';

  @override
  String get tagEstonianCuisine => 'Cozinha Estoniana';

  @override
  String get tagLatvianCuisine => 'Cozinha Letã';

  @override
  String get tagFinnishCuisine => 'Cozinha Finlandesa';

  @override
  String get tagCroatianCuisine => 'Cozinha Croata';

  @override
  String get tagSlovenianCuisine => 'Cozinha Eslovena';

  @override
  String get tagSlovakCuisine => 'Cozinha Eslovaca';

  @override
  String get tagRomanianCuisine => 'Cozinha Romena';

  @override
  String get tagBulgarianCuisine => 'Cozinha Búlgara';

  @override
  String get tagSerbianCuisine => 'Cozinha Sérvia';

  @override
  String get tagAlbanianCuisine => 'Cozinha Albanesa';

  @override
  String get tagGeorgianCuisine => 'Cozinha Georgiana';

  @override
  String get tagArmenianCuisine => 'Cozinha Armênia';

  @override
  String get tagAzerbaijaniCuisine => 'Cozinha Azerbaijana';

  @override
  String get tagUkrainianCuisine => 'Cozinha Ucraniana';

  @override
  String get tagBelarusianCuisine => 'Cozinha Bielorrussa';

  @override
  String get tagKazakhCuisine => 'Cozinha Cazaque';

  @override
  String get tagUzbekCuisine => 'Cozinha Uzbeque';

  @override
  String get tagKyrgyzCuisine => 'Cozinha Quirguiz';

  @override
  String get tagTurkmenCuisine => 'Cozinha Turcomena';

  @override
  String get tagTajikCuisine => 'Cozinha Tajique';

  @override
  String get tagMaldivianCuisine => 'Cozinha Maldiva';

  @override
  String get tagNepaleseCuisine => 'Cozinha Nepalesa';

  @override
  String get tagBangladeshiCuisine => 'Cozinha Bangladeshi';

  @override
  String get tagMyanmarCuisine => 'Cozinha Birmanesa';

  @override
  String get tagBruneianCuisine => 'Cozinha Bruneana';

  @override
  String get tagTaiwaneseCuisine => 'Cozinha Taiwanesa';

  @override
  String get tagNigerianCuisine => 'Cozinha Nigeriana';

  @override
  String get tagKenyanCuisine => 'Cozinha Queniana';

  @override
  String get tagGhanaianCuisine => 'Cozinha Ganense';

  @override
  String get tagEthiopianCuisine => 'Cozinha Etíope';

  @override
  String get tagSudaneseCuisine => 'Cozinha Sudanesa';

  @override
  String get tagTunisianCuisine => 'Cozinha Tunisiana';

  @override
  String get tagAngolanCuisine => 'Cozinha Angolana';

  @override
  String get tagCongoleseCuisine => 'Cozinha Congolesa';

  @override
  String get tagZimbabweanCuisine => 'Cozinha Zimbabuana';

  @override
  String get tagMalagasyCuisine => 'Cozinha Malgaxe';

  @override
  String get tagPapuaNewGuineanCuisine => 'Cozinha Papua-Nova Guiné';

  @override
  String get tagSamoanCuisine => 'Cozinha Samoana';

  @override
  String get tagTuvaluanCuisine => 'Cozinha Tuvaluana';

  @override
  String get tagFijianCuisine => 'Cozinha Fijiana';

  @override
  String get tagPalauanCuisine => 'Cozinha Palauana';

  @override
  String get tagKiribatiCuisine => 'Cozinha Kiribatiana';

  @override
  String get tagVanuatuanCuisine => 'Cozinha Vanuatuana';

  @override
  String get tagBahrainiCuisine => 'Cozinha Bahreiniana';

  @override
  String get tagQatariCuisine => 'Cozinha Catariana';

  @override
  String get tagKuwaitiCuisine => 'Cozinha Kuwaitiana';

  @override
  String get tagOmaniCuisine => 'Cozinha Omaniana';

  @override
  String get tagYemeniCuisine => 'Cozinha Iemenita';

  @override
  String get tagLebaneseCuisine => 'Cozinha Libanesa';

  @override
  String get tagSyrianCuisine => 'Cozinha Síria';

  @override
  String get tagJordanianCuisine => 'Cozinha Jordaniana';

  @override
  String get tagNoodles => 'Macarrão';

  @override
  String get tagMeatDishes => 'Pratos de Carne';

  @override
  String get tagFastFood => 'Fast Food';

  @override
  String get tagRiceDishes => 'Pratos de Arroz';

  @override
  String get tagSeafood => 'Frutos do Mar';

  @override
  String get tagBread => 'Pão';

  @override
  String get tagSweetsAndSnacks => 'Doces e Lanches';

  @override
  String get tagFruits => 'Frutas';

  @override
  String get tagVegetables => 'Legumes';

  @override
  String get tagBeverages => 'Bebidas';

  @override
  String get tagOthers => 'Outros';

  @override
  String get tagPasta => 'Macarrão';

  @override
  String get tagRamen => 'Ramen';

  @override
  String get tagSteak => 'Bife';

  @override
  String get tagYakiniku => 'Yakiniku';

  @override
  String get tagChicken => 'Frango';

  @override
  String get tagBacon => 'Bacon';

  @override
  String get tagHamburger => 'Hambúrguer';

  @override
  String get tagFrenchFries => 'Batatas Fritas';

  @override
  String get tagPizza => 'Pizza';

  @override
  String get tagTacos => 'Tacos';

  @override
  String get tagTamales => 'Tamales';

  @override
  String get tagGyoza => 'Gyoza';

  @override
  String get tagFriedShrimp => 'Camarão Frito';

  @override
  String get tagHotPot => 'Panela Quente';

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
  String get tagFish => 'Peixe';

  @override
  String get tagOctopus => 'Polvo';

  @override
  String get tagSquid => 'Lula';

  @override
  String get tagShrimp => 'Camarão';

  @override
  String get tagCrab => 'Caranguejo';

  @override
  String get tagShellfish => 'Mariscos';

  @override
  String get tagOyster => 'Ostra';

  @override
  String get tagSandwich => 'Sanduíche';

  @override
  String get tagHotDog => 'Cachorro-Quente';

  @override
  String get tagDonut => 'Donut';

  @override
  String get tagPancake => 'Panqueca';

  @override
  String get tagCroissant => 'Croissant';

  @override
  String get tagBagel => 'Bagel';

  @override
  String get tagBaguette => 'Baguete';

  @override
  String get tagPretzel => 'Pretzel';

  @override
  String get tagBurrito => 'Burrito';

  @override
  String get tagIceCream => 'Sorvete';

  @override
  String get tagPudding => 'Pudim';

  @override
  String get tagRiceCracker => 'Biscoito de Arroz';

  @override
  String get tagDango => 'Dango';

  @override
  String get tagShavedIce => 'Gelo Raspado';

  @override
  String get tagPie => 'Torta';

  @override
  String get tagCupcake => 'Cupcake';

  @override
  String get tagCake => 'Bolo';

  @override
  String get tagCandy => 'Doce';

  @override
  String get tagLollipop => 'Pirulito';

  @override
  String get tagChocolate => 'Chocolate';

  @override
  String get tagPopcorn => 'Pipoca';

  @override
  String get tagCookie => 'Biscoito';

  @override
  String get tagPeanuts => 'Amendoim';

  @override
  String get tagBeans => 'Feijão';

  @override
  String get tagChestnut => 'Castanha';

  @override
  String get tagFortuneCookie => 'Biscoito da Sorte';

  @override
  String get tagMooncake => 'Bolo da Lua';

  @override
  String get tagHoney => 'Mel';

  @override
  String get tagWaffle => 'Waffle';

  @override
  String get tagApple => 'Maçã';

  @override
  String get tagPear => 'Pera';

  @override
  String get tagOrange => 'Laranja';

  @override
  String get tagLemon => 'Limão';

  @override
  String get tagLime => 'Limão Verde';

  @override
  String get tagBanana => 'Banana';

  @override
  String get tagWatermelon => 'Melancia';

  @override
  String get tagGrapes => 'Uvas';

  @override
  String get tagStrawberry => 'Morango';

  @override
  String get tagBlueberry => 'Mirtilo';

  @override
  String get tagMelon => 'Melão';

  @override
  String get tagCherry => 'Cereja';

  @override
  String get tagPeach => 'Pêssego';

  @override
  String get tagMango => 'Manga';

  @override
  String get tagPineapple => 'Abacaxi';

  @override
  String get tagCoconut => 'Coco';

  @override
  String get tagKiwi => 'Kiwi';

  @override
  String get tagSalad => 'Salada';

  @override
  String get tagTomato => 'Tomate';

  @override
  String get tagEggplant => 'Beringela';

  @override
  String get tagAvocado => 'Abacate';

  @override
  String get tagGreenBeans => 'Vagem';

  @override
  String get tagBroccoli => 'Brócolis';

  @override
  String get tagLettuce => 'Alface';

  @override
  String get tagCucumber => 'Pepino';

  @override
  String get tagChili => 'Pimenta';

  @override
  String get tagBellPepper => 'Pimentão';

  @override
  String get tagCorn => 'Milho';

  @override
  String get tagCarrot => 'Cenoura';

  @override
  String get tagOlive => 'Azeitona';

  @override
  String get tagGarlic => 'Alho';

  @override
  String get tagOnion => 'Cebola';

  @override
  String get tagPotato => 'Batata';

  @override
  String get tagSweetPotato => 'Batata-Doce';

  @override
  String get tagGinger => 'Gengibre';

  @override
  String get tagShiitake => 'Shiitake';

  @override
  String get tagTeapot => 'Bule de Chá';

  @override
  String get tagCoffee => 'Café';

  @override
  String get tagTea => 'Chá';

  @override
  String get tagJuice => 'Suco';

  @override
  String get tagSoftDrink => 'Refrigerante';

  @override
  String get tagBubbleTea => 'Chá de Bolhas';

  @override
  String get tagSake => 'Sake';

  @override
  String get tagBeer => 'Cerveja';

  @override
  String get tagChampagne => 'Champagne';

  @override
  String get tagWine => 'Vinho';

  @override
  String get tagWhiskey => 'Uísque';

  @override
  String get tagCocktail => 'Coquetel';

  @override
  String get tagTropicalCocktail => 'Coquetel Tropical';

  @override
  String get tagMateTea => 'Chá Mate';

  @override
  String get tagMilk => 'Leite';

  @override
  String get tagKamaboko => 'Kamaboko';

  @override
  String get tagOden => 'Oden';

  @override
  String get tagCheese => 'Queijo';

  @override
  String get tagEgg => 'Ovo';

  @override
  String get tagFriedEgg => 'Ovo Frito';

  @override
  String get tagButter => 'Manteiga';

  @override
  String get done => 'Concluído';

  @override
  String get save => 'Salvar';

  @override
  String get searchFood => 'Pesquisar comida';

  @override
  String get noResultsFound => 'Nenhum resultado encontrado';

  @override
  String get searchCountry => 'Pesquisar país';

  @override
  String get searchEmptyTitle => 'Digite o nome do restaurante para pesquisar';

  @override
  String get searchEmptyHintTitle => 'Dicas de pesquisa';

  @override
  String get searchEmptyHintLocation =>
      'Ative a localização para mostrar resultados próximos primeiro';

  @override
  String get searchEmptyHintSearch =>
      'Pesquise por nome do restaurante ou tipo de cozinha';

  @override
  String get postErrorPickImage => 'Falha ao tirar foto';

  @override
  String get favoritePostEmptyTitle => 'Nenhuma postagem salva';

  @override
  String get favoritePostEmptySubtitle => 'Salve postagens que te interessam!';

  @override
  String get userInfoFetchError => 'Falha ao buscar informações do usuário';

  @override
  String get saved => 'Salvo';

  @override
  String get savedPosts => 'Postagens salvas';

  @override
  String get postSaved => 'Postagem salva';

  @override
  String get postSavedMessage =>
      'Você pode ver as postagens salvas na Minha página';

  @override
  String get noMapAppAvailable => 'Nenhum aplicativo de mapa disponível';

  @override
  String get notificationLunchTitle => '#Já postou a refeição de hoje? 🍜';

  @override
  String get notificationLunchBody =>
      'Que tal registrar o almoço de hoje enquanto ainda se lembra?';

  @override
  String get notificationDinnerTitle => '#Já postou a refeição de hoje? 🍛';

  @override
  String get notificationDinnerBody =>
      'Poste a refeição de hoje e termine o dia suavemente 📷';

  @override
  String get posted => 'postado';

  @override
  String get tutorialLocationTitle => 'Ative a Localização!';

  @override
  String get tutorialLocationSubTitle =>
      'Encontre ótimos lugares por perto.\nFacilite a descoberta de restaurantes.';

  @override
  String get tutorialLocationButton => 'Ativar';

  @override
  String get tutorialNotificationTitle => 'Ative as Notificações!';

  @override
  String get tutorialNotificationSubTitle => 'Lembretes para almoço e jantar';

  @override
  String get tutorialNotificationButton => 'Ativar';

  @override
  String get selectMapApp => 'Selecionar aplicativo de mapa';

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
  String get streakDialogFirstTitle => 'Publicação concluída';

  @override
  String get streakDialogFirstContent =>
      'Continue publicando\npara manter sequência';

  @override
  String get streakDialogContinueTitle => 'Publicação concluída';

  @override
  String streakDialogContinueContent(int weeks) {
    return '$weeks semanas consecutivas!\nContinue publicando\npara manter sequência';
  }

  @override
  String get translatableTranslate => 'Traduzir';

  @override
  String get translatableShowOriginal => 'Mostrar original';

  @override
  String get translatableCopy => 'Copiar';

  @override
  String get translatableCopied => 'Copiado para a área de transferência';

  @override
  String get translatableTranslateFailed => 'Falha na tradução';

  @override
  String get likeNotificationsTitle => 'Notificações de curtidas';

  @override
  String get loadFailed => 'Falha ao carregar';

  @override
  String get someoneLikedYourPost => 'Alguém curtiu sua publicação.';

  @override
  String userLikedYourPost(String name) {
    return '$name curtiu sua publicação.';
  }
}
