import UIKit
import Flutter
import CoinbaseWalletSDK

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(
      _ app: UIApplication, 
      open url: URL, 
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        // handle other types of deep links
        return false
    }
    
    override func application(
      _ application: UIApplication, 
      continue userActivity: NSUserActivity, 
      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL,
           (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        // handle other types of deep links
        return false
    }
}
