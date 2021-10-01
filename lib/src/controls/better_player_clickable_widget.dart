// Flutter imports:
import 'package:flutter/material.dart';

class BetterPlayerMaterialClickableWidget extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final FocusNode? focusNode;

  const BetterPlayerMaterialClickableWidget({
    Key? key,
    required this.onTap,
    required this.child,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: child,
        focusColor: Color.fromARGB(150, 51, 147, 208),
      ),
    );
  }
}
