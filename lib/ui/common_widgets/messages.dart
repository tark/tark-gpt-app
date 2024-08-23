import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';

import '../ui_constants.dart';
import 'texts.dart';
import 'chat_input.dart';

class ChatUI extends StatelessWidget {
  final List<Map<String, String>> messages;
  final bool showInitialMessage;
  final TextEditingController controller;
  final void Function() sendMessage;

  const ChatUI({
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
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUserMessage = message.containsKey('user');

                  return ListTile(
                    title: Align(
                      alignment: isUserMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: AppPadding.allNormal,
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? context.greenAccent
                              : context.cardBackground,
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
                                message['user']!,
                                fontWeight: FontWeight.w600,
                              )
                            : message.containsKey('loading')
                                ? Lottie.asset(AppAnimations.loadingAnimation,
                                    width: AppSize.animationSizeSmall)
                                : Texts(
                                    message['bot']!,
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
        ChatInputField(
          controller: controller,
          onSend: sendMessage,
        ),
      ],
    );
  }
}
