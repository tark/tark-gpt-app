import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tark_gpt_app/config/settings.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainState()) {
    _init();
  }

  Future<void> _init() async {
    final showOnboarding = await Settings.getShowOnboarding();
    if (!showOnboarding) {
      emit(state.copyWith(showOnboarding: true));
    } else {
      emit(state.copyWith(showOnboarding: false));
    }
  }

  void completeOnboarding() async {
    await Settings.setShowOnboarding(true);
    emit(state.copyWith(showOnboarding: false));
  }
}
