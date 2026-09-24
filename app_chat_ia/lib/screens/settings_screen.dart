import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _select(
      ThemeController controller, AppAppearance appearance) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await controller.select(appearance);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível salvar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeSettings.of(context);
    final colors = ChatPalette.of(context);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Configurações'),
        previousPageTitle: 'Chat',
      ),
      child: SafeArea(
          child: ListView(children: [
        CupertinoListSection.insetGrouped(
          backgroundColor: colors.background,
          header: const Text('APARÊNCIA'),
          footer: const Text(
              'Sistema acompanha automaticamente o modo claro ou escuro do dispositivo.'),
          children: AppAppearance.values
              .map((appearance) => CupertinoListTile(
                    key: ValueKey('appearance-${appearance.name}'),
                    title: Text(appearance.label),
                    leading: Icon(switch (appearance) {
                      AppAppearance.system =>
                        CupertinoIcons.device_phone_portrait,
                      AppAppearance.light => CupertinoIcons.sun_max,
                      AppAppearance.dark => CupertinoIcons.moon,
                    }),
                    trailing: controller.value == appearance
                        ? const Icon(CupertinoIcons.check_mark)
                        : null,
                    onTap:
                        _saving ? null : () => _select(controller, appearance),
                  ))
              .toList(),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_error!,
                style: TextStyle(
                    color: CupertinoColors.systemRed.resolveFrom(context))),
          ),
      ])),
    );
  }
}
