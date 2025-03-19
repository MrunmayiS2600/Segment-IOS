import UIKit
import Segment_CleverTap


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.makeKeyAndVisible()
        
        // Handle any push notification that may have opened the app
        if let notificationPayload = connectionOptions.notificationResponse?.notification.request.content.userInfo {
            Analytics.shared().receivedRemoteNotification(notificationPayload)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when the scene is being released by the syst  em
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when the scene is about to enter the foreground
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when the scene has entered the background
    }
}
