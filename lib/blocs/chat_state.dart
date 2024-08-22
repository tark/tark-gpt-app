part of 'chat_cubit.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatSuccess extends ChatState {
  final String response;

  const ChatSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class ChatFailure extends ChatState {
  final String error;

  const ChatFailure(this.error);

  @override
  List<Object?> get props => [error];
}
