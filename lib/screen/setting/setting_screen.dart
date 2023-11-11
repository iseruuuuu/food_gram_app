import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/mixin/url_launcher_mixin.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingScreen extends StatelessWidget with UrlLauncherMixin {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: <SettingsTile>[
              // SettingsTile.navigation(
              //   leading: const Icon(Icons.store),
              //   title: const Text('最新のバージョンを確認する'),
              //   onPressed: (context) {},
              // ),
              SettingsTile.navigation(
                leading: const Icon(FontAwesomeIcons.twitter),
                title: const Text('開発者'),
                onPressed: (context) {
                  launcherUrl('https://twitter.com/isekiryu');
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(FontAwesomeIcons.github),
                title: const Text('コントレビュートする'),
                onPressed: (context) {
                  launcherUrl('https://github.com/iseruuuuu/food_gram_app');
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('ライセンス'),
                onPressed: (context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LicensePage(),
                    ),
                  );
                },
              ),
              // SettingsTile.navigation(
              //   leading: const Icon(Icons.rate_review_outlined),
              //   title: const Text('レビューを書く'),
              //   onPressed: (context) {},
              // ),
              // SettingsTile.navigation(
              //   leading: const Icon(Icons.share),
              //   title: const Text('アプリを紹介する'),
              //   onPressed: (context) {},
              // ),
              // SettingsTile.navigation(
              //   leading: const Icon(Icons.star),
              //   title: const Text('このアプリを応援する'),
              //   onPressed: (context) {},
              // ),
              SettingsTile.navigation(
                leading: const Icon(Icons.question_answer),
                title: const Text('FAQ'),
                onPressed: (context) {
                  //TODO URLを飛ばす(アプリ内Safari)
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.lock),
                title: const Text('プライバシーポリシー'),
                onPressed: (context) {
                  //TODO URLを飛ばす(アプリ内Safari)
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.call),
                title: const Text('利用規約'),
                onPressed: (context) {
                  //TODO URLを飛ばす(アプリ内Safari)
                },
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.mail),
                title: const Text('お問い合わせ'),
                onPressed: (context) {
                  //TODO URLを飛ばす(アプリ内Safari)
                },
              ),
              SettingsTile(
                title: const Text('アプリのバージョン'),
                trailing: const Text('1.0.0'),
              ),
            ],
          ),
          SettingsSection(
            title: const Text('アカウント'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'ログアウト',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: (context) {},
              ),
              SettingsTile.navigation(
                leading: const Icon(Icons.delete_outline),
                title: const Text(
                  'アカウントの削除',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: (context) {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
