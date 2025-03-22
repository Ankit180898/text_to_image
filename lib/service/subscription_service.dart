import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Subscription tiers with features
enum SubscriptionTier { free, basic, premium, unlimited }

// Features that can be limited
class SubscriptionFeatures {
  final int imagesPerDay;
  final List<String> availableModels;
  final List<String> availableStyles;
  final bool highQualityEnabled;
  final bool customAspectRatioEnabled;
  final bool voiceToTextEnabled;
  final bool saveToGalleryEnabled;
  final bool shareEnabled;

  SubscriptionFeatures({
    required this.imagesPerDay,
    required this.availableModels,
    required this.availableStyles,
    required this.highQualityEnabled,
    required this.customAspectRatioEnabled,
    required this.voiceToTextEnabled,
    required this.saveToGalleryEnabled,
    required this.shareEnabled,
  });
}

class SubscriptionService extends GetxController {
  static String REVCAT_API_KEY_ANDROID = dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
  static const String REVCAT_API_KEY_IOS = 'YOUR_REVENUECAT_API_KEY_IOS';

  Rx<SubscriptionTier> currentTier = SubscriptionTier.free.obs;
  Rx<CustomerInfo?> customerInfo = Rx<CustomerInfo?>(null);
  RxBool isInitialized = false.obs;

  final RxInt imagesGeneratedToday = 0.obs;
  final RxString lastResetDate = ''.obs;

  // Available packages
  RxList<Package> availablePackages = <Package>[].obs;

  // Key for storing image count
  static const String IMAGE_COUNT_KEY = 'images_generated_today';
  static const String LAST_RESET_DATE_KEY = 'last_reset_date';

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await Purchases.setDebugLogsEnabled(true);

    PurchasesConfiguration configuration;
    if (Theme.of(Get.context!).platform == TargetPlatform.android) {
      configuration = PurchasesConfiguration(REVCAT_API_KEY_ANDROID);
    } else {
      configuration = PurchasesConfiguration(REVCAT_API_KEY_IOS);
    }

    await Purchases.configure(configuration);

    // Load stored image count
    await loadImageCount();

    // Check if day has changed and reset count if needed
    await checkAndResetDailyCount();

    // Get current customer info
    await refreshCustomerInfo();

    // Setup listener for purchases updates
    Purchases.addCustomerInfoUpdateListener((_customerInfo) {
      customerInfo.value = _customerInfo;
      updateSubscriptionTier();
    });

    // Mark as initialized
    isInitialized.value = true;
  }

  Future<void> loadImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    imagesGeneratedToday.value = prefs.getInt(IMAGE_COUNT_KEY) ?? 0;
    lastResetDate.value = prefs.getString(LAST_RESET_DATE_KEY) ?? '';
  }

  Future<void> checkAndResetDailyCount() async {
    final currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (lastResetDate.value != currentDate) {
      imagesGeneratedToday.value = 0;
      lastResetDate.value = currentDate;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(IMAGE_COUNT_KEY, 0);
      await prefs.setString(LAST_RESET_DATE_KEY, currentDate);
    }
  }

  // Increment the image generation count
  Future<void> incrementImageCount() async {
    // First check if we need to reset the count for a new day
    await checkAndResetDailyCount();

    imagesGeneratedToday.value++;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(IMAGE_COUNT_KEY, imagesGeneratedToday.value);
  }

  Future<void> refreshCustomerInfo() async {
    try {
      customerInfo.value = await Purchases.getCustomerInfo();
      updateSubscriptionTier();
    } catch (e) {
      debugPrint('Failed to get customer info: $e');
    }
  }

  void updateSubscriptionTier() {
    final info = customerInfo.value;
    if (info == null) {
      currentTier.value = SubscriptionTier.free;
      return;
    }

    // Check for active subscriptions
    // Replace these with your actual product identifiers
    if (info.entitlements.active.containsKey('unlimited')) {
      currentTier.value = SubscriptionTier.unlimited;
    } else if (info.entitlements.active.containsKey('premium')) {
      currentTier.value = SubscriptionTier.premium;
    } else if (info.entitlements.active.containsKey('basic')) {
      currentTier.value = SubscriptionTier.basic;
    } else {
      currentTier.value = SubscriptionTier.free;
    }
  }

  // Get subscription features based on current tier
  SubscriptionFeatures getFeatures() {
    switch (currentTier.value) {
      case SubscriptionTier.unlimited:
        return SubscriptionFeatures(
          imagesPerDay: 100,
          availableModels: ['stable-diffusion-v1-4', 'stable-diffusion-v2-1', 'sdxl', 'dalle-mini'],
          availableStyles: [
            'No Style',
            'Photorealistic',
            'Digital Art',
            'Illustration',
            'Anime',
            'Cinematic',
            'Neon',
            'Watercolor',
          ],
          highQualityEnabled: true,
          customAspectRatioEnabled: true,
          voiceToTextEnabled: true,
          saveToGalleryEnabled: true,
          shareEnabled: true,
        );

      case SubscriptionTier.premium:
        return SubscriptionFeatures(
          imagesPerDay: 30,
          availableModels: ['stable-diffusion-v1-4', 'stable-diffusion-v2-1', 'sdxl'],
          availableStyles: ['No Style', 'Photorealistic', 'Digital Art', 'Illustration', 'Anime', 'Cinematic'],
          highQualityEnabled: true,
          customAspectRatioEnabled: true,
          voiceToTextEnabled: true,
          saveToGalleryEnabled: true,
          shareEnabled: true,
        );

      case SubscriptionTier.basic:
        return SubscriptionFeatures(
          imagesPerDay: 10,
          availableModels: ['stable-diffusion-v1-4', 'stable-diffusion-v2-1'],
          availableStyles: ['No Style', 'Photorealistic', 'Digital Art', 'Illustration'],
          highQualityEnabled: false,
          customAspectRatioEnabled: true,
          voiceToTextEnabled: true,
          saveToGalleryEnabled: true,
          shareEnabled: true,
        );

      case SubscriptionTier.free:
      default:
        return SubscriptionFeatures(
          imagesPerDay: 3,
          availableModels: ['stable-diffusion-v1-4'],
          availableStyles: ['No Style', 'Photorealistic'],
          highQualityEnabled: false,
          customAspectRatioEnabled: false,
          voiceToTextEnabled: false,
          saveToGalleryEnabled: true,
          shareEnabled: false,
        );
    }
  }

  // Check if the user can generate more images today
  bool canGenerateImage() {
    final features = getFeatures();
    return imagesGeneratedToday.value < features.imagesPerDay;
  }

  // Get remaining image generations for today
  int getRemainingGenerations() {
    final features = getFeatures();
    return features.imagesPerDay - imagesGeneratedToday.value;
  }

  // Get available packages
  Future<List<Package>> getPackages() async {
    try {
      // Replace 'subscriptions' with your offering identifier in RevenueCat
      final offerings = await Purchases.getOfferings();
      final offering = offerings.getOffering('subscriptions');

      if (offering != null) {
        availablePackages.value = offering.availablePackages;
        return offering.availablePackages;
      }
      return [];
    } catch (e) {
      debugPrint('Failed to get packages: $e');
      return [];
    }
  }

  // Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      customerInfo.value = purchaserInfo;
      updateSubscriptionTier();
      return true;
    } catch (e) {
      debugPrint('Purchase failed: $e');
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      final restoredInfo = await Purchases.restorePurchases();
      customerInfo.value = restoredInfo;
      updateSubscriptionTier();
      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  String getTierName() {
    switch (currentTier.value) {
      case SubscriptionTier.unlimited:
        return "Unlimited";
      case SubscriptionTier.premium:
        return "Premium";
      case SubscriptionTier.basic:
        return "Basic";
      case SubscriptionTier.free:
      default:
        return "Free";
    }
  }
}
