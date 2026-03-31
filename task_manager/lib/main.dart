import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/task_provider.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
      child: const TaskManagerApp(),
    ),
  );
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Map design system tokens
    final Color primaryColor = const Color(0xFF1275E2);
    final Color secondaryColor = const Color(0xFF5F78A3);
    final Color tertiaryColor = const Color(0xFFC55B00);
    final Color neutralColor = const Color(0xFF74777F);

    final ColorScheme appColorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: const Color(0xFFF8F9FB), // Light background for contrast
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      outline: neutralColor,
    );

    // Roundedness: 2 (Moderate) -> Translated to 12px for Flutter
    final BorderRadius moderateRadius = BorderRadius.circular(12.0);

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: appColorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: appColorScheme.surface,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.black87, displayColor: Colors.black87),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: moderateRadius,
            side: BorderSide.none,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: moderateRadius),
          enabledBorder: OutlineInputBorder(
            borderRadius: moderateRadius,
            borderSide: BorderSide(color: neutralColor.withAlpha(102)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: moderateRadius,
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          labelStyle: GoogleFonts.inter(color: neutralColor),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: primaryColor.withAlpha(100),
            shape: RoundedRectangleBorder(borderRadius: moderateRadius),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600, 
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: primaryColor.withAlpha(38),
          elevation: 0,
          pressElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          showCheckmark: false,
          labelStyle: GoogleFonts.inter(color: secondaryColor, fontWeight: FontWeight.w600),
          secondaryLabelStyle: GoogleFonts.inter(
            color: primaryColor,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          side: BorderSide(color: neutralColor.withAlpha(80), width: 1.0),
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}
