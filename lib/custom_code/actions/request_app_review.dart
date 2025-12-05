import 'package:in_app_review/in_app_review.dart';

/// Request app review on iOS/Android
/// 
/// Opens the native app review dialog on iOS (SKStoreReviewController)
/// or Google Play review dialog on Android.
/// 
/// Returns true if the review dialog was shown, false otherwise.
Future<bool> requestAppReview() async {
  try {
    final InAppReview inAppReview = InAppReview.instance;

    // Check if the device supports in-app review
    if (await inAppReview.isAvailable()) {
      // Request review - this will show the native dialog
      await inAppReview.requestReview();
      return true;
    } else {
      // Fallback: open the app store directly
      // iOS
      await inAppReview.openStoreListing(
        appStoreId: '6753673667', // Lynewed iOS app ID
      );
      return true;
    }
  } catch (e) {
    // Silently fail - user can still access app store manually
    return false;
  }
}
