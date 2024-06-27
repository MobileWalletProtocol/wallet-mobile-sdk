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

      // See flutter/lib/coinbase_wallet_sdk.dart file for an explanation on this
      CoinbaseWalletSDK.configure(host: URL(string: "cbwallet://wsegue")!, callback: URL(string: "tribesxyzsample://mycallback")!)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    override func application(
      _ app: UIApplication, 
      open url: URL, 
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        guard CoinbaseWalletSDK.isConfigured else { return false }
        
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
        guard CoinbaseWalletSDK.isConfigured else { return false }
        
        if let url = userActivity.webpageURL,
           (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        // handle other types of deep links
        return false
    }
}
