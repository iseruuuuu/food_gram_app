part of '../router.dart';

final imageEditorRoute = GoRoute(
  path: RouterPath.imageEditor,
  name: RouterPath.imageEditor,
  pageBuilder: (context, state) {
    final imagePath = state.extra as String? ?? '';
    return MaterialPage(
      child: ImageEditorScreen(imagePath: imagePath),
    );
  },
);
