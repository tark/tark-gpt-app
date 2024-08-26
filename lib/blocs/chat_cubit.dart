import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tark_gpt_app/api/api.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final Api api;

  ChatCubit({required this.api}) : super(ChatState());

  Future<void> sendMessage(String userInput) async {
    emit(state.copyWith(isLoading: true, error: '', response: ''));

    try {
      final response = await api.sendMessageToOpenAI(userInput);
      emit(state.copyWith(isLoading: false, response: response));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, error: 'Error: Unable to fetch response.'));
    }
  }
}
