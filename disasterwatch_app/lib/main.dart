import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/eoc_theme.dart';
import 'services/api_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.loadSavedUrl();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: EOC.graphite,
  ));

  runApp(const DisasterWatchApp());
}

class DisasterWatchApp extends StatelessWidget {
  const DisasterWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DisasterWatch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: EOC.monoFont,
        scaffoldBackgroundColor: EOC.graphite,
        colorScheme: const ColorScheme.dark(
          primary: EOC.amber,
          secondary: EOC.cyan,
          surface: EOC.charcoal,
          error: EOC.critical,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
