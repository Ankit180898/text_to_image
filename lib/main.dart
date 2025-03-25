import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:text_to_image/app_bindings.dart';
import 'package:text_to_image/base_view.dart';

import 'views/onboarding_screen.dart';
import 'views/sign_in_screen.dart';
import 'views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
  );
  _initializeApp();

  runApp(const MyApp());
}

Future<void> _initializeApp() async {
  try {
    // Load environment variables
    await dotenv.dotenv.load(fileName: ".env");

    // Initialize Supabase
    await Supabase.initialize(
      url: dotenv.dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // Initialize RevenueCat
    await Purchases.configure(PurchasesConfiguration(dotenv.dotenv.env['REVENUECAT_PUBLIC_API_KEY']!));
  } catch (e) {
    print('Initialization error: $e');
    // Handle initialization errors
    Get.snackbar('Initialization Error', 'Failed to initialize app: $e', snackPosition: SnackPosition.BOTTOM);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090A13),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C39FF),
          secondary: const Color(0xFF9333EA),
          surface: const Color(0xFF1E1F2E),
        ),
      ),

      // Define initial route
      initialRoute: '/splash',
      initialBinding: AppBindings(),
      // Define named routes
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/signin', page: () => const SignInScreen()),
        GetPage(name: '/home', page: () => const TextToImageApp()),
      ],
    );
  }
}
