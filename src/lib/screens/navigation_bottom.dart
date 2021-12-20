import 'package:flutter/material.dart';
import 'package:saifu_air/widgets/drop_zone.dart';

class NavigationBottom extends StatelessWidget {
  const NavigationBottom({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: DropZone(),
      ),
    );
  }
}
