import 'package:better_player/src/controls/better_player_clickable_widget.dart';
import 'package:better_player/src/core/better_player_utils.dart';
import 'package:flutter/material.dart';

class BetterPlayerMaterialClickableFocusWidget extends StatefulWidget {
  final IconData icon;
  final String name;
  final void Function() onTap; 
  final bool autofocus;
  final Color color;
  final TextStyle Function(bool) style;
  final bool iconVisible;

  BetterPlayerMaterialClickableFocusWidget({required this.iconVisible, required this.icon, required this.name, required this.onTap, required this.autofocus, required this.color, required this.style});

  @override
  _BetterPlayerMaterialClickableFocusWidgetState createState() => _BetterPlayerMaterialClickableFocusWidgetState();
}

class _BetterPlayerMaterialClickableFocusWidgetState extends State<BetterPlayerMaterialClickableFocusWidget> {
  bool focus = false;

  @override
  void initState() {
    super.initState();
    focus = widget.autofocus;
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayerMaterialClickableWidget(
      onTap: widget.onTap,
      child: Container(
        child: Focus(
          autofocus: widget.autofocus,
          child: ListTile(
            leading:Visibility(
              visible: widget.iconVisible,
              child: Icon(
                Icons.check_outlined,
                color: widget.color,
              )
            ),
            title: Text(
              widget.name,
              style: widget.style(false),
            ),
            focusColor: Colors.blue,
            selected: focus,
            selectedTileColor: Colors.blueGrey.withOpacity(0.5),
          ),
          onFocusChange: (isFocus) {
            BetterPlayerUtils.log("Failed to parse subtitle line");
            setState(() {
              focus = isFocus;
            });
          }

          // child: Row(
          //   children: [
          //     const SizedBox(width: 8),
          //     Icon(
          //       icon,
          //       color: betterPlayerControlsConfiguration.overflowMenuIconsColor,
          //     ),
          //     const SizedBox(width: 16),
          //     Text(
          //       name,
          //       style: _getOverflowMenuElementTextStyle(false),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
