import UIKit
import Firebase
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Provide the Google Maps API key
    GMSServices.provideAPIKey("AIzaSyChvogVcovcqFYy-t365hv-SLzUtqHGp1I")

    // Configure Firebase
    FirebaseApp.configure()

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Return the result of the super implementation
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Handle remote notification registration
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Set the APNs token for Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
  }

  // Optional: Handle incoming notifications
  override func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    // Handle the notification data
    print("Received notification: \(userInfo)")

    // Call the completion handler with the appropriate result
    completionHandler(.newData)
  }
}