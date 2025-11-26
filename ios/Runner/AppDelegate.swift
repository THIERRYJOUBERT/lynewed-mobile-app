import UIKit
import Flutter
import GoogleMaps
import GooglePlaces
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
		// Initialize Google Maps SDK
		GMSServices.provideAPIKey("AIzaSyCLOe2yCKXS-yoxq4E4pHt2NTxG8OUbhuY")
		// Initialize Google Places SDK for native SDK validation
		GMSPlacesClient.provideAPIKey("AIzaSyCLOe2yCKXS-yoxq4E4pHt2NTxG8OUbhuY")
		// Register for Push Notifications
		// --- Code pour l'enregistrement des notifications push ---
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
application.registerForRemoteNotifications()
// --- Fin du code ---

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
