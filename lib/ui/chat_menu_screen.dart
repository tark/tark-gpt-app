import 'package:flutter/material.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import 'common_widgets/my_app_bar.dart';

import 'ui_constants.dart';
import 'chat_screen.dart';

class ChatMenuScreen extends StatefulWidget {
  const ChatMenuScreen({super.key});

  @override
  _ChatMenuScreenState createState() => _ChatMenuScreenState();
}

class _ChatMenuScreenState extends State<ChatMenuScreen> {
  final List<String> _previousChats = [];

  void _startNewChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(),
      ),
    ).then((value) {
      if (value != null) {
        setState(() {
          _previousChats.add(value as String);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        onTap: _startNewChat,
        title: "New Chat",
        iconPath: AppImages.chatIcon,
      ),
      backgroundColor: context.background,
      body: ListView.builder(
        itemCount: _previousChats.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_previousChats[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(chatTitle: _previousChats[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
