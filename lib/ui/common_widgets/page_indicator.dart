import 'package:flutter/material.dart';
import 'package:tark_gpt_app/ui/ui_constants.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final double width;
  final double height;
  final double gap;

  PageIndicator({
    required this.count,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
    this.width = 28.0,
    this.height = 2.0,
    this.gap = 8.0,  // Adjusted to create space between indicators
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: width,
          height: height,
          margin: EdgeInsets.only(right: index < count - 1 ? gap : 0),
          decoration: BoxDecoration(
            color: index == currentIndex ? activeColor : inactiveColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppSize.borderRadiusBig),
            ),
          ),
        );
      }),
    );
  }
}
