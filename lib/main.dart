import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_aqualink/app/providers/app_data_provider.dart';
import 'package:project_aqualink/app/screens/auth_screen.dart';
import 'package:project_aqualink/app/screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquaLinkApp());
}

class AquaLinkApp extends StatelessWidget {
  const AquaLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppDataProvider(),
      child: Consumer<AppDataProvider>(
        builder: (context, appData, _) {
          return MaterialApp(
            title: 'AquaLink',
            debugShowCheckedModeBanner: false,
            themeMode: appData.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: const Color(0xFFEAF8FA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF007C89),
                primary: const Color(0xFF007C89),
                secondary: const Color(0xFF00A7B5),
                surface: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                foregroundColor: Color(0xFF073B4C),
              ),
            ),
            darkTheme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF090909),
              cardColor: const Color(0xFF151515),
              dialogTheme: const DialogThemeData(
                backgroundColor: Color(0xFF121212),
              ),
              canvasColor: const Color(0xFF0D0D0D),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00B2CA),
                onPrimary: Colors.white,
                secondary: Color(0xFF80D7EA),
                onSecondary: Colors.white,
                surface: Color(0xFF141414),
                onSurface: Colors.white,
                error: Color(0xFFCF6679),
                onError: Colors.white,
                brightness: Brightness.dark,
              ),
              textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white70),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
              ),
            ),
            home: appData.isLoggedIn ? const MainShell() : const AuthScreen(),
          );
        },
      ),
    );
  }
}
