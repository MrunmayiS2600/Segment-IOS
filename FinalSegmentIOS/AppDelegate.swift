import UIKit
import Segment_CleverTap
import CleverTapSDK
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the Segment SDK with CleverTap integration
        CleverTap.autoIntegrate()
        CleverTap.setDebugLevel(CleverTapLogLevel.debug.rawValue)
        let config = AnalyticsConfiguration(writeKey: "JB9wHasH9i0ZETKF8veDLJAWCGFXxmLV")
        config.use(SEGCleverTapIntegrationFactory.instance())
        Analytics.setup(with: config)
        
        // Setup push notifications
        registerForPushNotifications(application)
        
        // Handle launch options if the app was launched from a push notification
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            Analytics.shared().receivedRemoteNotification(notification)
        }
        let localInAppBuilder = CTLocalInApp(inAppType: CTLocalInAppType.HALF_INTERSTITIAL,
                                             titleText: "Get Notified",
                                             messageText: "Please enable notifications on your device to use Push Notifications.",
                                             followDeviceOrientation: true,
                                             positiveBtnText: "Allow",
                                             negativeBtnText: "Cancel")

        // Optional fields.
        localInAppBuilder.setFallbackToSettings(true)
        localInAppBuilder.setBackgroundColor("#FFFFFF")
        localInAppBuilder.setTitleTextColor("#FF0000")
        localInAppBuilder.setMessageTextColor("#FF0000")
        localInAppBuilder.setBtnBorderRadius("4")
        localInAppBuilder.setBtnTextColor("#FF0000")
        localInAppBuilder.setBtnBorderColor("#FF0000")
        localInAppBuilder.setBtnBackgroundColor("#FFFFFF")
        localInAppBuilder.setImageUrl("https://icons.iconarchive.com/icons/treetog/junior/64/camera-icon.png")

        // Prompt Push Primer with above settings.
        CleverTap.sharedInstance()?.promptPushPrimer(localInAppBuilder.getSettings())
        return true
    }
    
    
    //Push Notification Setup
    
    func registerForPushNotifications(_ application: UIApplication) {
        // Request authorization for notifications
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to Segment
        Analytics.shared().registeredForRemoteNotifications(withDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Pass notification to Segment
        Analytics.shared().receivedRemoteNotification(userInfo)
        completionHandler(.noData)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Pass notification to Segment
        Analytics.shared().receivedRemoteNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification when app is in foreground
        completionHandler([.sound, .badge])
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session
    }
}
