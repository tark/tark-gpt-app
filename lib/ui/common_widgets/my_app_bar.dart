import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import '../ui_constants.dart';
import 'texts.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onTap;
  final String title;
  final String iconPath;

  const MyAppBar({
    Key? key,
    required this.onTap,
    required this.title,
    required this.iconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      title: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  height: AppSize.iconSizeSmall,
                ),
                Horizontal.medium(),
                Texts(
                  title,
                  fontSize: AppSize.fontNormal,
                  fontWeight: FontWeight.w700,
                  isCenter: true,
                ),
              ],
            ),
            SvgPicture.asset(
              AppImages.arrowForwardIcon,
              width: AppSize.iconSizeMicro,
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: Padding(
          padding: AppPadding.allNormal,
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: context.gray,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4.0);
}
