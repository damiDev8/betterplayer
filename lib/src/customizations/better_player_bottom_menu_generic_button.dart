// Flutter imports:
import 'package:flutter/material.dart';

///Menu item data used in overflow menu (3 dots).
class BetterPlayerBottomMenuGenericButton {
  ///Icon of menu item
  final IconData icon;

  ///Callback when item is clicked
  final void Function() onClicked;

  final BetterPlayerBottomMenuGenericButtonTypes? buttonType;

  BetterPlayerBottomMenuGenericButton(this.icon, this.onClicked, this.buttonType);
}

enum BetterPlayerBottomMenuGenericButtonTypes {
  GENERIC,
  SHOW_XRAY
}
