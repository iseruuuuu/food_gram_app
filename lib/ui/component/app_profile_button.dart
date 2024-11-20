import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

class AppMyProfileButton extends StatelessWidget {
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
          title: L10n.of(context).profileEditButton,
          onTap: onTapEdit,
          icon: Icons.edit,
        ),
        ProfileButton(
          title: L10n.of(context).profileExchangePointsButton,
          onTap: onTapExchange,
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
        elevation: 0,
      ),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
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
