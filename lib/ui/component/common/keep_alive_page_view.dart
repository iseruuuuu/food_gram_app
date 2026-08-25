import 'package:flutter/material.dart';

/// 一度開いたタブだけを構築し、以降は状態を保持する。
///
/// 切替は [IndexedStack] の上に短いスライド＋フェードを載せる。
/// [PageView] で画面全体をスワイプ移動させないので、マップなどの重いタブでも滑らか。
class KeepAlivePageView extends StatefulWidget {
  const KeepAlivePageView({
    required this.index,
    required this.children,
    super.key,
  });

  final int index;
  final List<Widget> children;

  @override
  State<KeepAlivePageView> createState() => _KeepAlivePageViewState();
}

class _KeepAlivePageViewState extends State<KeepAlivePageView>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 240);

  late final AnimationController _controller;
  late final Animation<double> _animation;
  late Animation<Offset> _slide;
  late Animation<double> _fade;
  late List<bool> _activated;
  int _direction = 1;

  @override
  void initState() {
    super.initState();
    _activated = List<bool>.generate(widget.children.length, (_) => false);
    _activated[widget.index] = true;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..value = 1;
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _updateTransitions();
  }

  void _updateTransitions() {
    _slide = Tween<Offset>(
      begin: Offset(0.055 * _direction, 0),
      end: Offset.zero,
    ).animate(_animation);
    _fade = Tween<double>(begin: 0.35, end: 1).animate(_animation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant KeepAlivePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children.length != _activated.length) {
      _activated = List<bool>.generate(
        widget.children.length,
        (i) => i < _activated.length && _activated[i],
      );
    }
    if (widget.index != oldWidget.index) {
      _direction = widget.index > oldWidget.index ? 1 : -1;
      _activated[widget.index] = true;
      _updateTransitions();
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: IndexedStack(
          index: widget.index,
          sizing: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              TickerMode(
                enabled: i == widget.index,
                child:
                    _activated[i] ? widget.children[i] : const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}
