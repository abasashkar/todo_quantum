import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todotask/app.dart';
import 'package:todotask/core/theme/app_theme.dart';
import 'package:todotask/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    AppTheme.systemUiOverlayStyle(Brightness.light),
  );
  await initDependencies();
  runApp(const TodoApp());
}
