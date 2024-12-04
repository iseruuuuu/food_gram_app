import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MapFloatingActionButton extends StatelessWidget {
  const MapFloatingActionButton({
    required this.onPressed,
    super.key,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: null,
          foregroundColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 10,
          shape: CircleBorder(side: BorderSide(color: Colors.white)),
          onPressed: onPressed,
          child: Icon(
            CupertinoIcons.location_fill,
            color: Color(0xFF1A73E8),
            size: 25,
          ),
        ),
      ),
    );
  }
}
