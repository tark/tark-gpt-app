import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tark_gpt_app/blocs/chat_cubit.dart';
import 'package:tark_gpt_app/api/api.dart';

import 'common_widgets/my_app_bar.dart';
import 'common_widgets/texts.dart';
import 'chat_screen.dart';
import 'ui_constants.dart';

class ChatMenuScreen extends StatefulWidget {
  const ChatMenuScreen({super.key});

  @override
  _ChatMenuScreenState createState() => _ChatMenuScreenState();
}

class _ChatMenuScreenState extends State<ChatMenuScreen> {
  List<String> _previousChats = [];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        onTap: _startNewChat,
        title: "New Chat",
        firstIconPath: AppImages.chatIcon,
        secondIconPath: AppImages.arrowForwardIcon,
        firstIconSize: AppSize.iconSizeSmall,
        secondIconSize: AppSize.iconSizeMicro,
      ),
      backgroundColor: context.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true, // Makes ListView only take as much space as needed
                physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                itemCount: _previousChats.length,
                itemBuilder: (context, index) {
                  final chatTitle = _previousChats[index];
                  return ListTile(
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
                              _editChatName(index);
                            } else if (value == 1) {
                              _deleteChat(index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 0, child: Texts('Edit')),
                            PopupMenuItem(
                              value: 1,
                              child: Texts(
                                'Delete',
                                color: context.red,
                              ),
                            ),
                          ],
                        ),
                        const Horizontal.small(),
                        SvgPicture.asset(
                          AppImages.arrowForwardIcon,
                          height: AppSize.iconSizeMicro,
                        ),
                      ],
                    ),
                    onTap: () => _openChat(chatTitle),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    tileColor: context.background,
                    shape: const Border(
                      bottom: BorderSide(color: AppColors.gray, width: 1.0),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _loadChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _previousChats = prefs.getStringList('chatHistory') ?? [];
    });
  }

  Future<void> _saveChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('chatHistory', _previousChats);
  }

  Future<void> _startNewChat() async {
    await _loadChatHistory();
    String newChatTitle = 'Chat ${_previousChats.length + 1}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatCubit(api: Api()),
          child: ChatScreen(chatTitle: newChatTitle),
        ),
      ),
    ).then((value) async {
      if (value != null && value is String && value.isNotEmpty) {
        setState(() {
          _previousChats.add(value);
        });
        await _saveChatHistory();
      }
    });
  }

  Future<void> _openChat(String chatTitle) async {
    await _loadChatHistory();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ChatCubit(api: Api()),
          child: ChatScreen(chatTitle: chatTitle),
        ),
      ),
    ).then((_) => _loadChatHistory());
  }

  void _editChatName(int index) {
    final TextEditingController editController =
        TextEditingController(text: _previousChats[index]);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Texts('Edit Chat Name'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "Enter new chat name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Texts('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _previousChats[index] = editController.text;
                });
                await _saveChatHistory();
                await _loadChatHistory();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteChat(int index) async {
    setState(() {
      _previousChats.removeAt(index);
    });
    await _saveChatHistory();
    await _loadChatHistory();
  }

}
