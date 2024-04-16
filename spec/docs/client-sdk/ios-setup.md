---
title: "Setup"
slug: "ios-setup"
category: "633d1d37bc7103008654c123"
---

Coinbase Wallet Mobile SDK uses [Universal Links](https://developer.apple.com/ios/universal-links/) to communicate between Coinbase Wallet and your application.

Before the SDK can be used, it needs to be configured with a Universal Link to your application. This callback URL will be used by the Coinbase Wallet application to navigate back to your application.

```swift
CoinbaseWalletSDK.configure(
    callback: URL(string: "https://myappxyz.com/mycallback")!
)
```

When your application receives a response from Coinbase Wallet via a Universal Link, this URL needs to be handed off to the SDK via the `handleResponse` function.

```swift
func application(_ app: UIApplication, open url: URL ...) -> Bool {
    if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
        return true
    }
    // handle other types of deep links
    return false
}
```

It’s recommended to place this configuration logic in the AppDelegate as shown in this [example](https://github.com/coinbase/wallet-mobile-sdk/blob/master/ios/example/SampleClient/AppDelegate.swift#L19).