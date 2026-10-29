import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/service_locator.dart';
import 'providers/auth_provider.dart';
import 'providers/prospect_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/audit_provider.dart';
import 'providers/task_provider.dart';
import 'providers/document_provider.dart';
import 'providers/custom_field_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/settings/database_config_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/main/main_screen.dart';
import 'screens/legal/legal_document_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/smooth_page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du Service Locator (DI)
  await sl.setup();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProspectProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
        ChangeNotifierProvider(create: (_) => AuditNotifier()),
        ChangeNotifierProvider(create: (_) => TransferNotifier()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => CustomFieldProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Prospectius',
            theme: ThemeData(
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.linux: SmoothPageTransitionsBuilder(),
                  TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
                  TargetPlatform.windows: SmoothPageTransitionsBuilder(),
                },
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.azure,
                primary: AppColors.azure,
                brightness: Brightness.light,
              ),
              scaffoldBackgroundColor: const Color(0xFFFAFBFF),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.azure,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.azure, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azure,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              fontFamily: GoogleFonts.lexend().fontFamily,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.linux: SmoothPageTransitionsBuilder(),
                  TargetPlatform.macOS: SmoothPageTransitionsBuilder(),
                  TargetPlatform.windows: SmoothPageTransitionsBuilder(),
                },
              ),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              fontFamily: GoogleFonts.lexend().fontFamily,
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[800]!),
                ),
              ),
              scaffoldBackgroundColor: const Color(0xFF121212),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade700),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              drawerTheme: const DrawerThemeData(
                backgroundColor: Color(0xFF1E1E1E),
              ),
            ),
            themeMode: settings.themeMode,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(settings.fontSizeFactor),
                ),
                child: child!,
              );
            },
            home: const AuthWrapper(),
            debugShowCheckedModeBanner: false,
            routes: {
              '/config': (_) => const DatabaseConfigScreen(),
              '/login': (_) => const LoginScreen(),
              '/prospects': (_) => const MainScreen(),
              '/terms': (_) => const LegalDocumentScreen(type: LegalDocumentType.terms),
              '/privacy': (_) => const LegalDocumentScreen(type: LegalDocumentType.privacy),
            },
          );
        },
      ),
    );
  }
}
