import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tark_gpt_app/blocs/chat_cubit.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common_widgets/texts.dart';
import 'common_widgets/my_app_bar.dart';
import 'ui_constants.dart';
import 'common_widgets/chat_input.dart';

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
        final title = widget.chatTitle ?? 'Chat ${DateTime.now().millisecondsSinceEpoch}';
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
                child: Stack(
                  children: [
                    // ListView.builder should take up available space
                    ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUserMessage = message.containsKey('user');

                        return ListTile(
                          title: Align(
                            alignment: isUserMessage
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: AppPadding.allNormal,
                              decoration: BoxDecoration(
                                color: isUserMessage ? context.greenAccent : context.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isUserMessage ? message['user']! : message['bot']!,
                                softWrap: true,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_showInitialMessage)
                      const Center(
                        child: Texts(
                          "Ask anything, get your answer",
                          fontSize: AppSize.fontNormal,
                          fontWeight: FontWeight.w600,
                          isCenter: true,
                        ),
                      ),
                  ],
                ),
              ),
              BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatSuccess) {
                    setState(() {
                      _messages.add({'bot': state.response});
                    });
                  }
                },
                builder: (context, state) {
                  return ChatInputField(
                    controller: _controller,
                    onSend: _sendMessage,
                  );
                },
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
    if (chatHistory != null) {
      setState(() {
        _messages = chatHistory
            .map((message) => {'bot': message})
            .toList();
      });
    }
  }

  void _saveChatHistory(String chatTitle) async {
    final prefs = await SharedPreferences.getInstance();
    final chatHistory = _messages.map((message) => message['bot'] ?? '').toList();
    prefs.setStringList(chatTitle, chatHistory);
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({'user': _controller.text});
        _showInitialMessage = false;
      });

      final userInput = _controller.text;
      _controller.clear();

      context.read<ChatCubit>().sendMessage(userInput);
    }
  }
}
