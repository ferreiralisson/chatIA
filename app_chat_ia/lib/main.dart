import 'package:flutter/cupertino.dart';

import 'screens/chat_screen.dart';
import 'services/chat_service.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key, this.service});

  final ChatService? service;

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatIA',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF202123),
        scaffoldBackgroundColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            fontSize: 15,
            color: Color(0xFF202123),
          ),
        ),
      ),
      home: ChatScreen(service: service),
    );
  }
}
