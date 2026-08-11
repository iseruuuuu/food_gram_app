import 'package:flutter/material.dart';

/// 各ページの状態を保持するPageViewのラッパー
class KeepAlivePageView extends StatelessWidget {
  const KeepAlivePageView({
    super.key,
    required this.controller,
    required this.children,
    this.physics,
    this.onPageChanged,
  });

  final PageController controller;
  final List<Widget> children;
  final ScrollPhysics? physics;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: controller,
      physics: physics,
      onPageChanged: onPageChanged,
      children: children.map((child) => _KeepAlivePage(child: child)).toList(),
    );
  }
}

/// 各ページを状態保持するラッパークラス
class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({required this.child});
  
  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixinに必要
    return widget.child;
  }
}