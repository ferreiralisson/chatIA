import 'package:flutter/cupertino.dart';

import 'screens/chat_screen.dart';
import 'services/chat_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await ThemeController.load();
  runApp(ChatApp(themeController: controller));
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key, this.service, this.themeController});

  final ChatService? service;
  final ThemeController? themeController;

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with WidgetsBindingObserver {
  late final ThemeController _controller =
      widget.themeController ?? ThemeController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.themeController == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ThemeSettings(
        controller: _controller,
        child: ValueListenableBuilder<AppAppearance>(
          valueListenable: _controller,
          builder: (context, appearance, _) {
            final brightness = switch (appearance) {
              AppAppearance.system =>
                WidgetsBinding.instance.platformDispatcher.platformBrightness,
              AppAppearance.light => Brightness.light,
              AppAppearance.dark => Brightness.dark,
            };
            final colors = ChatPalette(brightness == Brightness.dark);
            return CupertinoApp(
              debugShowCheckedModeBanner: false,
              title: 'ChatIA',
              theme: CupertinoThemeData(
                brightness: brightness,
                primaryColor: colors.text,
                scaffoldBackgroundColor: colors.background,
                barBackgroundColor: colors.background,
                textTheme: CupertinoTextThemeData(
                  textStyle: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      color: colors.text),
                ),
              ),
              home: ChatScreen(service: widget.service),
            );
          },
        ),
      );
}
