import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainState.initial()) {
    _init();
  }

  Future _init() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (!hasSeenOnboarding) {
      emit(state.copyWith(showOnboarding: true));
    } else {
      emit(state.copyWith(showOnboarding: false));
    }
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    emit(state.copyWith(showOnboarding: false));
  }
}
