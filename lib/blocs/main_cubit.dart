import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tark_gpt_app/config/settings.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final showOnboarding = await Settings.getShowOnboarding();
    if (!showOnboarding) {
      emit(const MainState.onboarding());
    } else {
      emit(const MainState.chatMainMenu());
    }
  }

  void completeOnboarding() async {
    await Settings.setShowOnboarding(true);
    emit(const MainState.chatMainMenu());
  }
}


