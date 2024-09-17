import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:tark_gpt_app/util/util.dart';
import 'package:tark_gpt_app/blocs/chat_cubit.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:tark_gpt_app/config/settings.dart';

import 'ui_constants.dart';
import 'common_widgets/texts.dart';
import 'common_widgets/buttons.dart';
import 'common_widgets/my_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String? chatTitle;

  const ChatScreen({this.chatTitle});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  var _showInitialMessage = true;
  var _isLoading = false;
  var _showRegenerateButton = false;
  List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    if (widget.chatTitle != null) {
      _loadChatHistory(widget.chatTitle ?? '');
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
        appBar: AppBar(
          centerTitle: true,
          title: Texts(
            'My chat',
            fontSize: AppSize.fontBig,
            fontWeight: FontWeight.w600,
            isCenter: true,
            color: context.secondary,
          ),
        ),
        drawer: Drawer(
          child: Container(
            color: context.background, // Set the background color to context's background color
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Texts(
                    'OpenAI API',
                      color: context.primary,
                      fontSize: AppSize.fontBig,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ListTile(
                    leading: Icon(Icons.audiotrack),
                    title: Text('Audio'),
                    onTap: () {

                    },
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: ListTile(
                    leading: Icon(Icons.chat),
                    title: Text('Chat'),
                    onTap: () {

                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        backgroundColor: context.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatCubit, ChatState>(
                  listener: (c, i) {
                    try {
                      setState(() {
                        _isLoading = i.isLoading;
                        if (i.isLoading) {
                          _showRegenerateButton = false;
                          _messages.add({'loading': ''});
                        } else if (i.response.isNotEmpty) {
                          _messages.removeWhere(
                                  (message) => message.containsKey('loading'));
                          _messages.add({'bot': i.response});
                          _showRegenerateButton = true;
                        } else if (i.error.isNotEmpty) {
                          showError(c, i.error);
                        }
                      });
                    } catch (e) {
                      showError(c, e.toString());
                    } finally {
                      if (!i.isLoading) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  builder: (c, i) {
                    return Chat(
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
    final chatHistory = await Settings.getChatHistory(chatTitle);
    if (chatHistory.isNotEmpty) {
      setState(() {
        _messages = chatHistory.map((message) {
          if (message.startsWith('user:')) {
            return {'user': message.substring(5)};
          } else if (message.startsWith('bot:')) {
            return {'bot': message.substring(4)};
          } else {
            return {'unknown': message};
          }
        }).toList();
        _showInitialMessage = false;
      });
    }
  }

  void _saveChatHistory(String chatTitle) async {
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
    await Settings.setChatHistory(chatTitle, chatHistory);
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

class Chat extends StatelessWidget {
  final List<Map<String, String>> messages;
  final bool showInitialMessage;
  final TextEditingController controller;
  final VoidCallback sendMessage;
  final VoidCallback? onRegenerate;
  final bool showRegenerateButton;

  const Chat({
    Key? key,
    required this.messages,
    required this.showInitialMessage,
    required this.controller,
    required this.sendMessage,
    this.onRegenerate,
    required this.showRegenerateButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUserMessage = message.containsKey('user');

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isUserMessage
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          const Vertical.small(),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  (isUserMessage ? 0.65 : 0.75),
                            ),
                            child: IntrinsicWidth(
                              child: Container(
                                padding: AppPadding.allNormal,
                                decoration: BoxDecoration(
                                  color: context.cardBackground,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: context.cardBackground,
                                    width: 1,
                                  ),
                                ),
                                child: isUserMessage
                                    ? Texts(
                                  message['user'],
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppSize.fontNormal,
                                  maxLines: 1000,
                                )
                                    : message.containsKey('loading')
                                    ? Lottie.asset(
                                    AppAnimations.loadingAnimation,
                                    width: AppSize.animationSizeSmall,
                                    height: AppSize.animationSizeSmall)
                                    : Texts(
                                  message['bot'],
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppSize.fontNormal,
                                  maxLines: 1000,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ),
                          if (!isUserMessage && message.containsKey('bot'))
                            CopyButton(message: message['bot'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (showInitialMessage)
                Center(
                  child: Texts(
                    "Ask anything, get your answer",
                    fontSize: AppSize.fontNormal,
                    fontWeight: FontWeight.w600,
                    color: context.gray,
                    isCenter: true,
                  ),
                ),
            ],
          ),
        ),
        if (showRegenerateButton && onRegenerate != null)
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              border: Border.all(color: context.gray, width: 1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Buttons(
              height: 35,
              buttonColor: context.black,
              onPressed: onRegenerate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AppImages.roundArrowsIcon,
                    height: AppSize.iconSizeMini,
                  ),
                  const Horizontal.small(),
                  const Texts(
                    'Regenerate response',
                    fontWeight: FontWeight.w500,
                    fontSize: AppSize.fontRegular,
                  ),
                ],
              ),
            ),
          ),
        ChatInput(
          controller: controller,
          onSend: sendMessage,
        ),
      ],
    );
  }
}

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.allNormal,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: AppPadding.allSmall,
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                    fontFamily: 'Raleway', fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  filled: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: onSend,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class CopyButton extends StatefulWidget {
  final message;

  const CopyButton({Key? key, required this.message}) : super(key: key);

  @override
  _CopyButtonState createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  var _buttonText = "Copy";

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message));
    setState(() {
      _buttonText = "Copied!";
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _buttonText = "Copy";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copyToClipboard,
      icon: SvgPicture.asset(
        AppImages.copyIcon,
        height: AppSize.iconSizeMini,
        color: context.gray,
      ),
      label: Texts(
        _buttonText,
        color: context.gray,
        fontSize: AppSize.fontRegular,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class Messages extends StatelessWidget {
  final messages;
  final showInitialMessage;
  final controller;
  final sendMessage;

  const Messages({
    Key? key,
    required this.messages,
    required this.showInitialMessage,
    required this.controller,
    required this.sendMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                itemCount: messages.length,
                itemBuilder: (c, i) {
                  final message = messages[i];
                  final isUserMessage = message.containsKey('user');

                  return ListTile(
                    title: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: AppPadding.allNormal,
                        decoration: BoxDecoration(
                          color:
                          isUserMessage ? c.greenAccent : c.cardBackground,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(8),
                            topRight: const Radius.circular(8),
                            bottomLeft: isUserMessage
                                ? const Radius.circular(8)
                                : const Radius.circular(0),
                            bottomRight: isUserMessage
                                ? const Radius.circular(0)
                                : const Radius.circular(8),
                          ),
                        ),
                        child: isUserMessage
                            ? Texts(
                          message['user'],
                          fontWeight: FontWeight.w600,
                        )
                            : message.containsKey('loading')
                            ? Lottie.asset(AppAnimations.loadingAnimation,
                            width: AppSize.animationSizeSmall)
                            : Texts(
                          message['bot'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (showInitialMessage)
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
        ChatInput(
          controller: controller,
          onSend: sendMessage,
        ),
      ],
    );
  }
}

