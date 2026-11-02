import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import 'theme/app_theme.dart';

class MeloApp extends StatefulWidget {
  const MeloApp({super.key, this.initialLocation = AppRoutes.splash});

  /// Overridable so tests can start on a specific screen.
  final String initialLocation;

  @override
  State<MeloApp> createState() => _MeloAppState();
}

class _MeloAppState extends State<MeloApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Melo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}
