part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final String response;
  final String error;

  const ChatState({
    this.isLoading = false,
    this.response = '',
    this.error = '',
  });

  ChatState copyWith({
    bool? isLoading,
    String? response,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, response, error];
}
