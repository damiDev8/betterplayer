// Flutter imports:
import 'package:flutter/material.dart';

///Menu item data used in overflow menu (3 dots).
class BetterPlayerBottomMenuGenericButton {
  ///Icon of menu item
  final IconData icon;

  ///Callback when item is clicked
  final Function(void Function) onClicked;

  BetterPlayerBottomMenuGenericButton(this.icon, this.onClicked);
}
