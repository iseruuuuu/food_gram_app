import 'package:flutter/material.dart';
import 'package:food_gram_app/gen/l10n/l10n.dart';

String authErrorManager(String error, BuildContext context) {
  switch (error) {
    case 'Unable to validate email address: invalid format':
      return L10n.of(context).authInvalidFormat;
    default:
      return L10n.of(context).authSocketException;
  }
}
