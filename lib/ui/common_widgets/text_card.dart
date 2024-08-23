import 'package:flutter/material.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import '../ui_constants.dart';

import 'texts.dart';

class TextCard extends StatelessWidget {
  final String text;

  const TextCard({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: AppPadding.horizontalHuge, // Add horizontal padding
        child: Texts(
          // Assuming 'Texts' is your custom text widget
          text,
          fontSize: AppSize.fontNormal,
          fontWeight: FontWeight.w500,
          isCenter: true,
          maxLines: 3,
        ),
      ),
    );
  }
}
