import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:tark_gpt_app/util/context_extensions.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'texts.dart';
import '../ui_constants.dart';
import 'chat_input.dart';
import 'buttons.dart';

class ChatUI extends StatelessWidget {
  final List<Map<String, String>> messages;
  final bool showInitialMessage;
  final TextEditingController controller;
  final void Function() sendMessage;
  final void Function()? onRegenerate;
  final bool showRegenerateButton; // New flag to control button visibility

  const ChatUI({
    Key? key,
    required this.messages,
    required this.showInitialMessage,
    required this.controller,
    required this.sendMessage,
    this.onRegenerate,
    required this.showRegenerateButton, // Required flag
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
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width *
                                  (isUserMessage ? 0.65 : 0.75),
                            ),
                            child: IntrinsicWidth(
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
                                        fontSize: AppSize.fontNormal,
                                        maxLines: 1000,
                                      )
                                    : message.containsKey('loading')
                                        ? Lottie.asset(
                                            AppAnimations.loadingAnimation,
                                            width: AppSize.animationSizeSmall,
                                            height: AppSize.animationSizeSmall)
                                        : Texts(
                                            message['bot']!,
                                            fontWeight: FontWeight.w600,
                                            fontSize: AppSize.fontNormal,
                                            maxLines: 1000,
                                            overflow: TextOverflow.visible,
                                          ),
                              ),
                            ),
                          ),
                          if (!isUserMessage && message.containsKey('bot'))
                            CopyButton(message: message['bot']!),
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
          Buttons(
            width: 250,
            buttonColor: context.black,
            onPressed: onRegenerate!,
            borderColor: Colors.white,
            borderWidth: 2,
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
                  fontWeight: FontWeight.w600,
                  fontSize: AppSize.fontNormal,
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

class CopyButton extends StatefulWidget {
  final String message;

  const CopyButton({Key? key, required this.message}) : super(key: key);

  @override
  _CopyButtonState createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  String _buttonText = "Copy";

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
