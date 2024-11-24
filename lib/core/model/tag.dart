final countryCategory = [
  '🇯🇵', // 和食
  '🇮🇹', // イタリアン
  '🇫🇷', // フレンチ
  '🇨🇳', // 中華料理
  '🇮🇳', // インド料理
  '🇲🇽', // メキシカン
  '🇺🇸', // アメリカ料理
  '🇲🇹', // 地中海料理
  '🇹🇭', // タイ料理
  '🇬🇷', // ギリシャ料理
  '🇹🇷', // トルコ料理
  '🇰🇷', // 韓国料理
  '🇷🇺', // ロシア料理
  '🇪🇸', // スペイン料理
  '🇻🇳', // ベトナム料理
  '🇵🇹', // ポルトガル料理
  '🇦🇹', // オーストリア料理
  '🇧🇪', // ベルギー料理
  '🇸🇪', // スウェーデン料理
  '🇩🇪', // ドイツ料理
  '🇬🇧', // イギリス料理
  '🇳🇱', // オランダ料理
  '🇦🇺', // オーストラリア料理
  '🇧🇷', // ブラジル料理
  '🇦🇷', // アルゼンチン料理
  '🇨🇴', // コロンビア料理
  '🇵🇪', // ペルー料理
  '🇳🇴', // ノルウェー料理
  '🇩🇰', // デンマーク料理
  '🇵🇱', // ポーランド料理
  '🇨🇿', // チェコ料理
  '🇭🇺', // ハンガリー料理
  '🇿🇦', // 南アフリカ料理
  '🇪🇬', // エジプト料理
  '🇲🇦', // モロッコ料理
  '🇳🇿', // ニュージーランド料理
  '🇵🇭', // フィリピン料理
  '🇲🇾', // マレーシア料理
  '🇸🇬', // シンガポール料理
  '🇮🇩', // インドネシア料理
  '🇮🇷', // イラン料理
  '🇸🇦', // サウジアラビア料理
  '🇲🇳', // モンゴル料理
  '🇰🇭', // カンボジア料理
  '🇱🇦', // ラオス料理
  '🇨🇺', // キューバ料理
  '🇯🇲', // ジャマイカ料理
  '🇨🇱', // チリ料理
  '🇻🇪', // ベネズエラ料理
  '🇵🇦', // パナマ料理
  '🇧🇴', // ボリビア料理
  '🇮🇸', // アイスランド料理
  '🇱🇹', // リトアニア料理
  '🇪🇪', // エストニア料理
  '🇱🇻', // ラトビア料理
  '🇫🇮', // フィンランド料理
  '🇭🇷', // クロアチア料理
  '🇸🇮', // スロベニア料理
  '🇸🇰', // スロバキア料理
  '🇷🇴', // ルーマニア料理
  '🇧🇬', // ブルガリア料理
  '🇷🇸', // セルビア料理
  '🇦🇱', // アルバニア料理
  '🇬🇪', // ジョージア料理
  '🇦🇲', // アルメニア料理
  '🇦🇿', // アゼルバイジャン料理
  '🇺🇦', // ウクライナ料理
  '🇧🇾', // ベラルーシ料理
  '🇰🇿', // カザフスタン料理
  '🇺🇿', // ウズベキスタン料理
  '🇰🇬', // キルギス料理
  '🇹🇲', // トルクメニスタン料理
  '🇹🇯', // タジキスタン料理
  '🇲🇻', // モルディブ料理
  '🇳🇵', // ネパール料理
  '🇧🇩', // バングラデシュ料理
  '🇲🇲', // ミャンマー料理
  '🇧🇳', // ブルネイ料理
  '🇹🇼', // 台湾料理
  '🇳🇬', // ナイジェリア料理
  '🇰🇪', // ケニア料理
  '🇬🇭', // ガーナ料理
  '🇪🇹', // エチオピア料理
  '🇸🇩', // スーダン料理
  '🇹🇳', // チュニジア料理
  '🇦🇴', // アンゴラ料理
  '🇨🇩', // コンゴ料理
  '🇿🇼', // ジンバブエ料理
  '🇲🇬', // マダガスカル料理
  '🇵🇬', // パプアニューギニア料理
  '🇼🇸', // サモア料理
  '🇹🇻', // ツバル料理
  '🇫🇯', // フィジー料理
  '🇵🇼', // パラオ料理
  '🇰🇮', // キリバス料理
  '🇻🇺', // バヌアツ料理
  '🇧🇭', // バーレーン料理
  '🇶🇦', // カタール料理
  '🇰🇼', // クウェート料理
  '🇴🇲', // オマーン料理
  '🇾🇪', // イエメン料理
  '🇱🇧', // レバノン料理
  '🇸🇾', // シリア料理
  '🇯🇴', // ヨルダン料理
];

final foodCategory = [
  // 麺類
  '🍜', // ラーメン
  '🍝', // パスタ
  '🍲', // 煮物
  '🍛', // カレー

  // ファストフード・軽食
  '🍔', // ファストフード
  '🌭', // ホットドッグ
  '🥪', // サンドイッチ
  '🌮', // タコス
  '🍕', // ピザ
  '🌯', // ブリトー

  // 肉類・シーフード
  '🍖', // 肉
  '🥩', // ステーキ
  '🍗', // フライドチキン
  '🍤', // エビ
  '🦀', // カニ
  '🍣', // 寿司
  '🥟', // 餃子
  '🍡', // だんご

  // ご飯・パスタ系
  '🍚', // ご飯
  '🍝', // スパゲティ
  '🍳', // 卵料理
  '🥘', // 鍋料理

  // デザート・お菓子
  '🍰', // デザート
  '🍪', // クッキー
  '🍩', // ドーナツ
  '🍫', // チョコレート
  '🍯', // ハチミツ
  '🍮', // プリン
  '🍦', // アイスクリーム
  '🍧', // かき氷
  '🍨', // シャーベット

  // ドリンク
  '🍹', // ドリンク
  '🍸', // カクテル
  '🍷', // ワイン
  '🍺', // ビール
  '🥛', // 牛乳
  '🥂', // シャンパン
  '🥃', // ウィスキー
  '🍾', // シャンパンボトル
  '🍶', // 日本酒
  '🍵', // 緑茶
  '🥤', // ソフトドリンク
  '🍻', // ビールジョッキ
  '🍋', // レモンティー
  '🍇', // グレープジュース
  '🍊', // オレンジジュース

  // パン・サンドイッチ
  '🍞', // パン
  '🥖', // フランスパン
  '🥐', // クロワッサン

  // その他
  '🍠', // サツマイモ
];
