import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:tark_gpt_app/ui/widgets/my_input.dart';
import 'package:tark_gpt_app/blocs/chat_cubit.dart';
import 'package:tark_gpt_app/api/api.dart';
import 'package:tark_gpt_app/config/settings.dart';

import 'common_widgets/texts.dart';
import 'common_widgets/my_app_bar.dart';
import 'chat_screen.dart';
import 'ui_constants.dart';

class ChatMenuScreen extends StatefulWidget {
  const ChatMenuScreen({super.key});

  @override
  _ChatMenuScreenState createState() => _ChatMenuScreenState();
}

class _ChatMenuScreenState extends State<ChatMenuScreen> {
  var _previousChats = <String>[];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Texts(
          'Chat menu',
          fontSize: AppSize.fontBig,
          fontWeight: FontWeight.w600,
          isCenter: true,
          color: context.secondary,
        ),
      ),
      backgroundColor: c.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allNormal,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _previousChats.length,
                itemBuilder: (c, i) {
                  final chatTitle = _previousChats[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: c.cardBackground, // Background color
                      borderRadius: BorderRadius.circular(30), // Border radius
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      leading: SvgPicture.asset(
                        AppImages.chatIcon,
                        height: AppSize.iconSizeSmall,
                      ),
                      title: Texts(
                        chatTitle,
                        fontSize: AppSize.fontNormal,
                        fontWeight: FontWeight.w500,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<int>(
                            icon: SvgPicture.asset(
                              AppImages.editIcon,
                              height: AppSize.iconSizeMicro,
                            ),
                            onSelected: (value) {
                              if (value == 0) {
                                _editChatName(i);
                              } else if (value == 1) {
                                _deleteChat(i);
                              }
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(
                                value: 0,
                                child: Texts(
                                  'Edit',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Texts(
                                  'Delete',
                                  color: c.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => _openChat(chatTitle),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: context.cardBackground,
        shape: const CircleBorder(),
        child: Icon(
          Icons.add,
          color: context.secondary,
        ),
      ),
    );
  }

  Future<void> _loadChatHistory() async {
    final chatList = await Settings.getChatList();
    setState(() {
      _previousChats = chatList;
    });
  }

  Future<void> _saveChatHistory() async {
    await Settings.saveChatList(_previousChats);
  }

  Future<void> _startNewChat() async {
    _loadChatHistory();
    await _loadChatHistory();

    String newChatTitle = 'Chat ${_previousChats.length + 1}';
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatCubit(
              api: Api(),
          ),
          child: ChatScreen(chatTitle: newChatTitle),
        ),
      ),
    );

    if (result != null && result is String && result.isNotEmpty) {
      final chatHistory = await Settings.getChatHistory(result);

      if (chatHistory.isNotEmpty) {
        if (!_previousChats.contains(result)) {
          setState(() {
            _previousChats.add(result);
          });
          await _saveChatHistory();
        }
      }
    }
  }

  Future<void> _openChat(String chatTitle) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => BlocProvider(
          create: (c) => ChatCubit(
            api: Api(),
          ),
          child: ChatScreen(chatTitle: chatTitle),
        ),
      ),
    );
    await _loadChatHistory();
  }

  void _editChatName(int index) async {
    final oldTitle = _previousChats[index];
    final editController = TextEditingController(text: oldTitle);
    showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          backgroundColor: c.background,
          title: const Texts(
            'Edit Chat Name',
            fontWeight: FontWeight.w600,
            fontSize: AppSize.fontNormal,
          ),
          content: MyInput(
            controller: editController,
            hint: "Chat name",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(c).pop();
              },
              child: const Texts('Cancel', fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = editController.text;
                if (newTitle.isNotEmpty) {
                  await Settings.editChatName(oldTitle, newTitle);
                  setState(() {
                    _previousChats[index] = newTitle;
                  });
                  await _saveChatHistory();
                  await _loadChatHistory();
                }
                Navigator.of(c).pop();
              },
              child: const Texts('Save', fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(int index) async {
    final chatTitleToDelete = _previousChats[index];

    setState(() {
      _previousChats.removeAt(index);
    });

    await Settings.deleteChat(chatTitleToDelete);

    await _saveChatHistory();
    await _loadChatHistory();
  }
}
