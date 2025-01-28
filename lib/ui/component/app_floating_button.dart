import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppFloatingButton extends StatelessWidget {
  const AppFloatingButton({
    required this.onTap,
    super.key,
  });

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: FloatingActionButton(
        heroTag: null,
        foregroundColor: Colors.black,
        backgroundColor: Colors.black,
        elevation: 10,
        shape: CircleBorder(side: BorderSide()),
        onPressed: onTap,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}

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
        width: 55,
        height: 55,
        child: Theme(
          data: Theme.of(context).copyWith(highlightColor: Colors.white),
          child: FloatingActionButton(
            heroTag: null,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(14),
            ),
            foregroundColor: Colors.white,
            backgroundColor: Colors.white,
            focusColor: Colors.white,
            splashColor: Colors.white,
            hoverColor: Colors.white,
            elevation: 10,
            onPressed: onPressed,
            child: Icon(
              CupertinoIcons.location_fill,
              color: Color(0xFF1A73E8),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}
