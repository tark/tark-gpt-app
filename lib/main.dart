import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'api/api.dart';
import 'blocs/main_cubit.dart';
import 'ui/guide_screen.dart';
import 'ui/theme/dark_theme.dart';
import 'ui/theme/light_theme.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF343541), // Set the desired color here
    statusBarColor: Color(0xFF343541),
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await dotenv.load(fileName: ".env");

  final api = Api();

  runApp(MyApp(
    api: api,
  ));
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
          create: (c) => MainCubit(
          ),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: GuideScreen(),
      ),
    );
  }
}
