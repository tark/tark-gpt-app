import 'dart:async';

import 'package:flutter/material.dart';

import '../util/log.dart';
import 'common_widgets/texts.dart';
import 'ui_constants.dart';

class GuideScreen extends StatefulWidget {
  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Color(0xFF343541),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Texts(
              "Welcome to ",
              fontSize: 32,
              fontWeight: FontWeight.w700,
              isCenter: true,
            ),
            Texts(
              "ChatGPT",
              fontSize: 32,
              fontWeight: FontWeight.w700,
              isCenter: true,
            ),
          ],
        ),
      ),
    );
  }

}
