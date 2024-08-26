import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import 'api/api.dart';
import 'blocs/main_cubit.dart';
import 'blocs/chat_cubit.dart';
import 'ui/guide_screen.dart';
import 'ui/chat_menu_screen.dart';
import 'ui/theme/dark_theme.dart';
import 'ui/theme/light_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(api: Api()));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.api,
  });

  final Api api;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MainCubit>(
          create: (context) => MainCubit(), // MainCubit doesn't need the Api
          lazy: false,
        ),
      ],
      child: Builder(
        builder: (context) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            systemNavigationBarColor: context.background,
            statusBarColor: context.background,
            systemNavigationBarDividerColor: Colors.transparent,
            statusBarIconBrightness:
                context.isDark ? Brightness.light : Brightness.dark,
          ));

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            home: BlocBuilder<MainCubit, MainState>(
              builder: (c, i) {
                if (i.showOnboarding) {
                  return const GuideScreen();
                } else {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider<ChatCubit>(
                        create: (context) => ChatCubit(api: api),
                      ),
                    ],
                    child: const ChatMenuScreen(),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
