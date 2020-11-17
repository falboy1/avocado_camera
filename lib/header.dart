import 'package:flutter/material.dart';

// AppBarに代入されるウィジェット
class Header extends StatelessWidget with PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.more_horiz_outlined),
        onPressed: () {},
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.history),
          onPressed: () {},
        ),
      ],
    );
  }
}
