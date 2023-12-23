import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/utils/mixin/snack_bar_mixin.dart';

class AppMyProfileButton extends StatelessWidget with SnackBarMixin {
  const AppMyProfileButton({
    required this.onTapEdit,
    required this.onTapExchange,
    super.key,
  });

  final Function() onTapEdit;
  final Function() onTapExchange;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ProfileButton(
          title: 'プロフィールを編集',
          onTap: onTapEdit,
          icon: Icons.edit,
        ),
        ProfileButton(
          title: 'ポイントを交換する',
          onTap: () {
            EasyDebounce.debounce('exchange point', Duration(seconds: 1),
                () async {
              openComingSoonSnackBar(context);
            });
          },
          icon: FontAwesomeIcons.coins,
        ),
      ],
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    required this.title,
    required this.onTap,
    required this.icon,
    super.key,
  });

  final String title;
  final Function() onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        elevation: 5,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
