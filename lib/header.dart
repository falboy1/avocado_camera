import 'package:flutter/material.dart';

// AppBarに代入されるウィジェット
class Header extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        color: Colors.black54,
        icon: Icon(
          Icons.more_horiz_rounded,
          color: Colors.black54,
        ),
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          color: Colors.black54,
          icon: Icon(Icons.history),
          onPressed: () {},
        ),
      ],
    );
  }
}
