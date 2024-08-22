import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tark_gpt_app/api/api.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final Api api;

  ChatCubit({required this.api}) : super(ChatInitial());

  Future<void> sendMessage(String userInput) async {
    emit(ChatLoading());

    try {
      final response = await api.sendMessageToOpenAI(userInput);
      emit(ChatSuccess(response));
    } catch (e) {
      emit(ChatFailure('Error: Unable to fetch response.'));
    }
  }
}
