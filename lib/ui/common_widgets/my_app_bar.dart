import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import '../ui_constants.dart';
import 'texts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final String title;
  final String firstIconPath;
  final String secondIconPath;
  final double firstIconSize;
  final double secondIconSize;

  const MyAppBar({
    Key? key,
    required this.onTap,
    required this.title,
    required this.firstIconPath,
    required this.secondIconPath,
    required this.firstIconSize,
    required this.secondIconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray, width: 1.0),
        ),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    firstIconPath,
                    height: firstIconSize,
                  ),
                  const Horizontal.medium(),
                  Texts(
                    title,
                    fontSize: AppSize.fontNormal,
                    fontWeight: FontWeight.w700,
                    isCenter: true,
                  ),
                ],
              ),
              SvgPicture.asset(
                secondIconPath,
                height: secondIconSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
