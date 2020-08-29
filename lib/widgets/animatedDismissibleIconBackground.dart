import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AnimatedDismissibleIconBackground extends AnimatedWidget {
  final IconData iconData;

  const AnimatedDismissibleIconBackground({
    @required Listenable listenable,
    @required this.iconData,
  }) : super(listenable: listenable);

  Animation<double> get size => listenable;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FaIcon(
        iconData,
        color: Colors.red,
        size: 150 * size.value,
      ),
    );
  }
}
