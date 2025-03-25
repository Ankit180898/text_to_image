import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class AuthController extends GetxController {
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;

  // Supabase client
  final supabase = Supabase.instance.client;

  @override
  void onInit() {
    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        currentUser.value = supabase.auth.currentUser;
        _syncUserWithSupabase();
      } else if (event == AuthChangeEvent.signedOut) {
        currentUser.value = null;
      }
    });
    super.onInit();
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      // Get Google auth credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Sign in to Supabase with Google credentials
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
      );

      // Set current user
      currentUser.value = response.user;

      // Sync user details with Supabase users table
      await _syncUserWithSupabase();

      // Configure RevenueCat
      await _configureRevenueCat(response.user!.id);

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Google Sign-In failed: $e');
    }
  }

  Future<void> _syncUserWithSupabase() async {
    if (currentUser.value == null) return;

    try {
      // Upsert user in Supabase users table
      await supabase.from('users').upsert({
        'id': currentUser.value!.id,
        'email': currentUser.value!.email,
        'name': currentUser.value!.userMetadata?['full_name'] ?? '',
        'avatar_url': currentUser.value!.userMetadata?['avatar_url'] ?? '',
        'last_sign_in': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (e) {
      print('Error syncing user: $e');
    }
  }

  Future<void> _configureRevenueCat(String userId) async {
    try {
      // Configure RevenueCat with Supabase user ID
      var id = dotenv.env['REVENUECAT_PUBLIC_API_KEY'];
      await Purchases.configure(
        PurchasesConfiguration(id.toString())
          ..appUserID = userId
      );
    } catch (e) {
      print('RevenueCat configuration error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      await GoogleSignIn().signOut();
      await Purchases.logOut();
      currentUser.value = null;
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed: $e');
    }
  }
}