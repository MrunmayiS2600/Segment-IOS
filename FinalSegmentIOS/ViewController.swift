import UIKit
import CleverTapSDK
import Segment_CleverTap
import SDWebImage

class ViewController: UIViewController, CleverTapDisplayUnitDelegate {
    private let loginButton = UIButton(type: .system)
    private let trackEventButton = UIButton(type: .system)
    private let inappbutton = UIButton(type: .system)
    private let purchaseButton = UIButton(type: .system)
    private let showAppInboxButton = UIButton(type: .system)
    private let pushNotificationButton = UIButton(type: .system)
    private let nativeDisplay = UIButton(type: .system)
    
    // UIImageView for Native Display
    private let nativeDisplayImageView = UIImageView()
    // Add property to store the latest display unit
    private var latestDisplayUnit: CleverTapDisplayUnit?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initializeAppInbox()
        registerAppInbox()
        
        // Set the display unit delegate
        CleverTap.sharedInstance()?.setDisplayUnitDelegate(self)
        print("📝 Display Unit Delegate Set!")
        
        // Add tap gesture to the image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(nativeDisplayTapped(_:)))
        nativeDisplayImageView.isUserInteractionEnabled = true
        nativeDisplayImageView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "Segment-CleverTap Demo"
        
        // Configure buttons
        setupButton(loginButton, title: "Login User", action: #selector(loginUser))
        setupButton(trackEventButton, title: "Track Event", action: #selector(trackEvent))
        setupButton(inappbutton, title: "InApp Notification", action: #selector(inapp))
        setupButton(purchaseButton, title: "Complete Purchase", action: #selector(completePurchase))
        setupButton(showAppInboxButton, title: "Show App Inbox", action: #selector(showAppInbox))
        setupButton(pushNotificationButton, title: "Send Push Notification", action: #selector(sendPushNotification))
        setupButton(nativeDisplay, title: "Native Display", action: #selector(nativeD))
        
        // Configure Native Display Image View
        nativeDisplayImageView.translatesAutoresizingMaskIntoConstraints = false
        nativeDisplayImageView.contentMode = .scaleAspectFit
        nativeDisplayImageView.backgroundColor = .lightGray
        nativeDisplayImageView.layer.cornerRadius = 8
        nativeDisplayImageView.clipsToBounds = true
        
        view.addSubview(nativeDisplayImageView)
        
        // Stack view for better layout
        let stackView = UIStackView(arrangedSubviews: [loginButton, trackEventButton,inappbutton, purchaseButton, showAppInboxButton, pushNotificationButton, nativeDisplay])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 200),
            
            // Add constraints for the image view
            nativeDisplayImageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            nativeDisplayImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nativeDisplayImageView.widthAnchor.constraint(equalToConstant: 250),
            nativeDisplayImageView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    // MARK: - Button Actions
    
    @objc private func loginUser() {
        // Push user information using Segment's identify method
        let floatAttribute = 12.3
        let intAttribute = 18
        let traits: [String: Any] = [
          "email": "support@clevertap.com",
          "bool": true,
          "floatAttribute": floatAttribute,
          "intAttribute" : intAttribute,
          "name": "Segment CleverTap",
          "phone" : "0234567891",
          "gender": "female",
        ]
                
        Analytics.shared().identify("cleverTapSegementTestUseriOS", traits: traits)
    }
    
    
    @objc private func trackEvent() {
        Analytics.shared().track("cleverTapSegmentTrackEvent", properties: ["eventProperty":"eventPropertyValue"])
    }
    @objc private func inapp()
    {
        Analytics.shared().track("CleverTapInApp", properties: ["source": "button_click"])
        CleverTap.sharedInstance()?.recordEvent("In-app Notification Triggered");
        
    }
    
    @objc private func completePurchase() {
        Analytics.shared().track("Order Completed", properties: ["orderId": "123456",
                                                                 "revenue": "100",
                                                                 "Products": [["id1","sku1","100.0"],
                                                                              ["id2","sku2","200.0"]]])
    }
    
    @objc private func sendPushNotification() {
        // Track that user requested a push notification
        Analytics.shared().track("Push Notification Requested", properties: ["source": "button_click"])
        
        CleverTap.sharedInstance()?.recordEvent("Android Event");
    }
    
    @objc private func nativeD() {
        // Track that user requested a native display
        Analytics.shared().track("Native Display", properties: ["source": "button_click"])
        
        CleverTap.sharedInstance()?.recordEvent("Native Display");
    }
    
    // Add the native display tap handler
    @objc private func nativeDisplayTapped(_ sender: UITapGestureRecognizer) {
        // Ensure we have a valid displayUnit
        if let displayUnit = latestDisplayUnit, let unitID = displayUnit.unitID {
            CleverTap.sharedInstance()?.recordDisplayUnitClickedEvent(forID: unitID)
            print("🔊 Notification Clicked Event Recorded for ID: \(unitID)")
        } else {
            print("⚠️ No Display Unit Available for Click Event")
        }
    }
    
    @objc private func showAppInbox() {
        // Show the CleverTap App Inbox
        let style = CleverTapInboxStyleConfig()
        style.navigationTintColor = .black
        Analytics.shared().track("AppInbox")
        if let inboxController = CleverTap.sharedInstance()?.newInboxViewController(with: style, andDelegate: self) {
            let navigationController = UINavigationController(rootViewController: inboxController)
            present(navigationController, animated: true)
        } else {
            showAlert(title: "App Inbox Error", message: "Could not open App Inbox")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - App Inbox Integration
    
    private func initializeAppInbox() {
        CleverTap.sharedInstance()?.initializeInbox { success in
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount() ?? 0
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount() ?? 0
            print("Inbox Message: \(messageCount)/\(unreadCount)")
        }
    }
    
    private func registerAppInbox() {
        CleverTap.sharedInstance()?.registerInboxUpdatedBlock {
            let messageCount = CleverTap.sharedInstance()?.getInboxMessageCount() ?? 0
            let unreadCount = CleverTap.sharedInstance()?.getInboxMessageUnreadCount() ?? 0
            print("Inbox Message updated: \(messageCount)/\(unreadCount)")
        }
    }
    
    // MARK: - CleverTap Display Unit Delegate
    
    func displayUnitsUpdated(_ displayUnits: [CleverTapDisplayUnit]) {
        print("📝 Native Display Units Updated: \(displayUnits.count)")
        for unit in displayUnits {
            latestDisplayUnit = unit // Store the latest unit
            if let unitID = unit.unitID {
                print("🔊 Received Display Unit ID: \(unitID)")
                let contents = unit.contents ?? []
                for content in contents {
                    if let imageUrl = content.mediaUrl {
                        print("✅ Image URL: \(imageUrl)")
                        DispatchQueue.main.async {
                            self.nativeDisplayImageView.sd_setImage(with: URL(string: imageUrl), completed: nil)
                            // Record Notification Viewed Event
                            CleverTap.sharedInstance()?.recordDisplayUnitViewedEvent(forID: unitID)
                            print("🔊 Notification Viewed Event Recorded for ID: \(unitID)")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - CleverTapInboxViewControllerDelegate

extension ViewController: CleverTapInboxViewControllerDelegate {
    func messageDidSelect(_ message: CleverTapInboxMessage, at index: Int32, withButtonIndex buttonIndex: Int32) {
        print("Message selected at index: \(index) with button index: \(buttonIndex)")
        Analytics.shared().track("App Inbox Message Clicked", properties: [
            "messageId": message.messageId ?? "",
            "index": index,
            "buttonIndex": buttonIndex
        ])
    }
}
