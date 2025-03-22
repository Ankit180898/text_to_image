import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:text_to_image/service/subscription_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final subscriptionService = Get.find<SubscriptionService>();
  bool isLoading = true;
  List<Package> packages = [];

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> loadPackages() async {
    setState(() {
      isLoading = true;
    });
    final availablePackages = await subscriptionService.getPackages();
    setState(() {
      packages = availablePackages;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF090A13), Color(0xFF0F1024)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 40,
                floating: false,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text(
                    'Subscription Plans',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  titlePadding: EdgeInsets.only(left: 60, bottom: 16),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upgrade your Vision AI experience',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unlock premium features and generate more images',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      Obx(() => _buildCurrentPlanInfo()),
                      
                      const SizedBox(height: 30),
                      
                      // Usage statistics
                      Obx(() => _buildUsageStatistics()),
                      
                      const SizedBox(height: 30),
                      
                      // Plan comparison
                      _buildPlanComparison(),
                      
                      const SizedBox(height: 30),
                      
                      // Available packages
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : packages.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No subscription plans available',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Column(
                                  children: packages.map((package) {
                                    return _buildPackageCard(package);
                                  }).toList(),
                                ),
                      
                      const SizedBox(height: 20),
                      
                      // Restore purchases button
                      Center(
                        child: TextButton.icon(
                          onPressed: _restorePurchases,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          label: const Text(
                            'Restore Purchases',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Terms and Privacy
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Navigate to terms of service
                              },
                              child: const Text(
                                'Terms of Service',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () {
                                // Navigate to privacy policy
                              },
                              child: const Text(
                                'Privacy Policy',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Subscriptions will automatically renew unless canceled',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCurrentPlanInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            color: _getTierColor(subscriptionService.currentTier.value),
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subscriptionService.getTierName()} Plan',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subscriptionService.currentTier.value == SubscriptionTier.free
                      ? 'Upgrade to generate more images'
                      : 'Your subscription is active',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (subscriptionService.currentTier.value != SubscriptionTier.free)
            TextButton(
              onPressed: () {
                // Navigate to manage subscription
              },
              child: const Text('Manage'),
            ),
        ],
      ),
    );
  }
  
  Widget _buildUsageStatistics() {
    final remaining = subscriptionService.getRemainingGenerations();
    final features = subscriptionService.getFeatures();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Usage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: subscriptionService.imagesGeneratedToday.value / features.imagesPerDay,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTierColor(subscriptionService.currentTier.value),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${subscriptionService.imagesGeneratedToday.value} used',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                '$remaining remaining',
                style: TextStyle(
                  color: remaining < 3 ? Colors.orange : Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlanComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Plan Comparison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 40,
              dataRowHeight: 40,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              columns: const [
                DataColumn(label: Text('Feature')),
                DataColumn(label: Text('Free')),
                DataColumn(label: Text('Basic')),
                DataColumn(label: Text('Premium')),
                DataColumn(label: Text('Unlimited')),
              ],
              rows: [
                _buildFeatureRow(
                  'Daily Images',
                  ['3', '10', '30', '100'],
                ),
                _buildFeatureRow(
                  'AI Models',
                  ['1', '2', '3', '4'],
                ),
                _buildFeatureRow(
                  'Art Styles',
                  ['2', '4', '6', '8'],
                ),
                _buildFeatureRow(
                  'High Quality',
                  ['✗', '✗', '✓', '✓'],
                ),
                _buildFeatureRow(
                  'Custom Aspect Ratio',
                  ['✗', '✓', '✓', '✓'],
                ),
                _buildFeatureRow(
                  'Voice to Text',
                  ['✗', '✓', '✓', '✓'],
                ),
                _buildFeatureRow(
                  'Share',
                  ['✗', '✓', '✓', '✓'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  DataRow _buildFeatureRow(String feature, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(feature, style: const TextStyle(color: Colors.white))),
        DataCell(Text(values[0], style: const TextStyle(color: Colors.grey))),
        DataCell(Text(
          values[1],
          style: TextStyle(
            color: subscriptionService.currentTier.value == SubscriptionTier.basic
                ? _getTierColor(SubscriptionTier.basic)
                : Colors.grey,
            fontWeight: subscriptionService.currentTier.value == SubscriptionTier.basic
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        )),
        DataCell(Text(
          values[2],
          style: TextStyle(
            color: subscriptionService.currentTier.value == SubscriptionTier.premium
                ? _getTierColor(SubscriptionTier.premium)
                : Colors.grey,
            fontWeight: subscriptionService.currentTier.value == SubscriptionTier.premium
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        )),
        DataCell(Text(
          values[3],
          style: TextStyle(
            color: subscriptionService.currentTier.value == SubscriptionTier.unlimited
                ? _getTierColor(SubscriptionTier.unlimited)
                : Colors.grey,
            fontWeight: subscriptionService.currentTier.value == SubscriptionTier.unlimited
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        )),
      ],
    );
  }
  
  Widget _buildPackageCard(Package package) {
    final offering = package.storeProduct.title
        .replaceAll('(Vision AI Pro)', '')
        .trim();
    final price = package.storeProduct.priceString;
    
    // Determine what tier this package corresponds to
    SubscriptionTier packageTier = SubscriptionTier.free;
    
    if (package.identifier.contains('unlimited')) {
      packageTier = SubscriptionTier.unlimited;
    } else if (package.identifier.contains('premium')) {
      packageTier = SubscriptionTier.premium;
    } else if (package.identifier.contains('basic')) {
      packageTier = SubscriptionTier.basic;
    }
    
    final isCurrentTier = subscriptionService.currentTier.value == packageTier;
    final tierColor = _getTierColor(packageTier);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentTier
              ? [tierColor.withOpacity(0.3), tierColor.withOpacity(0.1)]
              : [const Color(0xFF272A4D), const Color(0xFF171931)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentTier ? tierColor : const Color(0xFF3D416E),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: isCurrentTier ? null : () => _purchasePackage(package),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  _getTierIcon(packageTier),
                  color: tierColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offering,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 16,
                          color: tierColor,
                        ),
                      ),
                    ],
                  ),
                ),
                isCurrentTier
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: tierColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: tierColor),
                        ),
                        child: Text(
                          'Current',
                          style: TextStyle(
                            color: tierColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _purchasePackage(Package package) async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final success = await subscriptionService.purchasePackage(package);
      
      // Show success message
      if (success) {
        Get.snackbar(
          'Success',
          'Subscription activated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to purchase subscription: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Future<void> _restorePurchases() async {
    try {
      setState(() {
        isLoading = true;
      });
      
      final success = await subscriptionService.restorePurchases();
      
      Get.snackbar(
        success ? 'Success' : 'Info',
        success 
            ? 'Purchases restored successfully!' 
            : 'No previous purchases found to restore.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: success ? Colors.green : Colors.blue,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to restore purchases: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  
  Color _getTierColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.unlimited:
        return const Color(0xFFE040FB); // Purple
      case SubscriptionTier.premium:
        return const Color(0xFF00BCD4); // Teal
      case SubscriptionTier.basic:
        return const Color(0xFF4CAF50); // Green
      case SubscriptionTier.free:
      return const Color(0xFFFFD700); // Gold/Yellow
    }
  }
  
  IconData _getTierIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.unlimited:
        return Icons.auto_awesome;
      case SubscriptionTier.premium:
        return Icons.workspace_premium;
      case SubscriptionTier.basic:
        return Icons.star;
      case SubscriptionTier.free:
      return Icons.emoji_emotions;
    }
  }
}