---
title: "Install"
slug: "ios-install"
category: "633d1d37bc7103008654c123"
---

The Coinbase Wallet Mobile SDK is available on both [CocoaPods](https://cocoapods.org/) and [Swift Package Manager](https://swift.org/package-manager).

## Cocoapods

Add Coinbase Wallet SDK to your `Podfile`.

```ruby
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'CoinbaseWalletSDK', '1.0.3'
end
```

Replace `YOUR_TARGET_NAME`, and then in the `Podfile` directory run:

```bash
pod install
```

## Swift Package Manager

Add Coinbase Wallet SDK to your `Package.swift` file.

Under **File > Add packages…** enter the package url: [https://github.com/coinbase/wallet-mobile-sdk](https://github.com/coinbase/wallet-mobile-sdk)

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/coinbase/wallet-mobile-sdk.git", from: "1.0.3"),
    ]
)
```

Replace `YOUR_PROJECT_NAME`, and then run:

```bash
swift build
```