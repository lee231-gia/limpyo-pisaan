import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'auth.dart';
import 'shell.dart';
import 'state.dart';
import 'ui.dart';

class LimpyoApp extends StatelessWidget {
  final AppState state;
  const LimpyoApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Limpyo Pisaan',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: cream,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: kIsWeb
          ? ColoredBox(
              color: pale,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: child!,
                ),
              ),
            )
          : child!,
    ),
    home: AnimatedBuilder(
      animation: state,
      builder: (context, _) => state.stage == AuthStage.app
          ? AppShell(state: state)
          : AuthScreen(state: state),
    ),
  );
}
