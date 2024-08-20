import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import '../ui_constants.dart';
import 'texts.dart';

class SliderPage extends StatelessWidget {
  final String iconPath;
  final String title;
  final List<Widget> cards;

  const SliderPage({
    super.key,
    required this.iconPath,
    required this.title,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.allZero,
      child: Column(
        children: [
          const Vertical.big(),
          SvgPicture.asset(
            iconPath,
            height: AppSize.iconSizeSmall,
          ),
          const Vertical.big(),
          Texts(
            title,
            fontSize: AppSize.fontMedium,
            fontWeight: FontWeight.w500,
            isCenter: true,
          ),
          const Vertical.big(),
          for (int i = 0; i < cards.length; i++) ...[
            cards[i],
            if (i < cards.length - 1) const Vertical.medium(),
          ],
        ],
      ),
    );
  }
}
