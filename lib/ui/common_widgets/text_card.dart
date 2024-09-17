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
      width: double.infinity,
      alignment: Alignment.center,
      padding: AppPadding.allNormal,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: context.cardBackground,
          width: 1,
        ),
      ),
      child: Texts(
        text,
        fontSize: AppSize.fontNormal,
        fontWeight: FontWeight.w500,
        isCenter: true,
        maxLines: 100,
      ),
    );
  }
}
