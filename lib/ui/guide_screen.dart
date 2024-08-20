import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'common_widgets/texts.dart';
import 'common_widgets/text_card.dart';
import 'common_widgets/buttons.dart';
import 'common_widgets/page_indicator.dart';
import 'common_widgets/slider_page.dart';
import '../blocs/main_cubit.dart';
import 'ui_constants.dart';


class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_pageController.page != null && _pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_pageController.page == 2) {
      context.read<MainCubit>().completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF343541),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.allBig,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppImages.gptIcon,
                  height: AppSize.iconSize,
                ),
                const Vertical.big(),
                const Texts(
                  "Welcome to",
                  fontSize: AppSize.fontBigExtra,
                  fontWeight: FontWeight.w700,
                  isCenter: true,
                ),
                const Texts(
                  "ChatGPT",
                  fontSize: AppSize.fontBigExtra,
                  fontWeight: FontWeight.w700,
                  isCenter: true,
                ),
                const Vertical.big(),
                const Texts(
                  "Ask anything, get your answer",
                  fontSize: AppSize.fontNormal,
                  fontWeight: FontWeight.w600,
                  isCenter: true,
                ),
                const Vertical.big(),
                SizedBox(
                  height: 400.0, // Specify a fixed height for PageView
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      SliderPage(
                        iconPath: AppImages.examplesIcon,
                        title: "Examples",
                        cards: [
                          TextCard(text: "“Explain quantum computing in simple terms”"),
                          TextCard(text: "“Got any creative ideas for a 10 year old’s birthday?”"),
                          TextCard(text: "“How do I make an HTTP request in JavaScript?”"),
                        ],
                      ),
                      SliderPage(
                        iconPath: AppImages.capabilitiesIcon,
                        title: "Capabilities",
                        cards: [
                          TextCard(text: "Remembers what user said earlier in the conversation"),
                          TextCard(text: "Allows user to provide follow-up corrections"),
                          TextCard(text: "Trained to decline inappropriate requests"),
                        ],
                      ),
                      SliderPage(
                        iconPath: AppImages.limitationsIcon,
                        title: "Limitations",
                        cards: [
                          TextCard(text: "May occasionally generate incorrect information"),
                          TextCard(text: "May occasionally produce harmful instructions or biased content"),
                          TextCard(text: "Limited knowledge of world and events after 2021"),
                        ],
                      ),
                    ],
                  ),
                ),
                const Vertical.big(),
                PageIndicator(
                  count: 3,
                  currentIndex: _currentPage,
                  activeColor: const Color(0xFF10A37F),
                  inactiveColor: const Color(0x33FFFFFF),
                ),
                const Vertical.big(),
                Container(
                  width: double.infinity,
                  child: Buttons(
                    onPressed: _nextPage,
                    buttonColor: const Color(0xFF10A37F),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Texts(
                          _currentPage == 2 ? "Let's Chat" : "Next",
                          fontSize: AppSize.fontNormalBig,
                          fontWeight: FontWeight.w700,
                          isCenter: true,
                        ),
                        if (_currentPage == 2)
                          Padding(
                            padding: AppPadding.leftSmall,
                            child: SvgPicture.asset(
                              AppImages.arrowRightIcon,
                              height: AppSize.iconSizeMicro,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
