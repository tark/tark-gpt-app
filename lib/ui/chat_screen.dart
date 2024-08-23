import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tark_gpt_app/blocs/chat_cubit.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common_widgets/my_app_bar.dart';
import 'common_widgets/chat.dart';
import 'common_widgets/texts.dart';
import 'ui_constants.dart';

class ChatScreen extends StatefulWidget {
  final String? chatTitle;

  const ChatScreen({this.chatTitle});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _showInitialMessage = true;
  bool _isLoading = false;
  bool _showRegenerateButton = false;

  @override
  void initState() {
    super.initState();
    if (widget.chatTitle != null) {
      _loadChatHistory(widget.chatTitle!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final title =
            widget.chatTitle ?? 'Chat ${DateTime.now().millisecondsSinceEpoch}';
        _saveChatHistory(title);
        Navigator.of(context).pop(title);
        return false;
      },
      child: Scaffold(
        appBar: MyAppBar(
          onTap: () {
            if (widget.chatTitle != null) {
              _saveChatHistory(widget.chatTitle!);
            }
            Navigator.of(context).pop(widget.chatTitle ?? 'Untitled Chat');
          },
          title: widget.chatTitle ?? 'Back',
          firstIconPath: AppImages.arrowBackIcon,
          secondIconPath: AppImages.gptIcon,
          firstIconSize: AppSize.iconSizeMicro,
          secondIconSize: AppSize.iconSizeSmall,
        ),
        backgroundColor: context.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (context, state) {
                    if (state is ChatLoading) {
                      setState(() {
                        _isLoading = true;
                        _showRegenerateButton = false;
                        _messages.add({'loading': ''});
                      });
                    } else if (state is ChatSuccess) {
                      setState(() {
                        _isLoading = false;
                        _messages.removeWhere(
                            (message) => message.containsKey('loading'));
                        _messages.add({'bot': state.response});
                        _showRegenerateButton = true;
                      });
                    }
                  },
                  builder: (context, state) {
                    return ChatUI(
                      messages: _messages,
                      showInitialMessage: _showInitialMessage,
                      controller: _controller,
                      sendMessage: _sendMessage,
                      onRegenerate: _regenerateResponse,
                      showRegenerateButton: _showRegenerateButton,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadChatHistory(String chatTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistory = prefs.getStringList(chatTitle);
    if (chatHistory != null && chatHistory.isNotEmpty) {
      setState(() {
        _messages = chatHistory.map((message) {
          final isUser = message.startsWith('user:');
          return {isUser ? 'user' : 'bot': message.substring(4)};
        }).toList();
        _showInitialMessage = false;
      });
    }
  }

  void _saveChatHistory(String chatTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistory = _messages.map((message) {
      final userMessage = message['user'];
      final botMessage = message['bot'];
      if (userMessage != null) {
        return 'user:$userMessage';
      } else if (botMessage != null) {
        return 'bot:$botMessage';
      }
      return '';
    }).toList();
    prefs.setStringList(chatTitle, chatHistory);
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'user': _controller.text});
        _showInitialMessage = false;
        _showRegenerateButton = false;
      });

      final userInput = _controller.text;
      _controller.clear();

      context.read<ChatCubit>().sendMessage(userInput);
    }
  }

  void _regenerateResponse() {
    if (_messages.isNotEmpty) {
      final lastUserMessage =
          _messages.lastWhere((message) => message.containsKey('user'))['user'];
      if (lastUserMessage != null) {
        context.read<ChatCubit>().sendMessage(lastUserMessage);
      }
    }
  }
}
