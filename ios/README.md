# Coinbase Wallet Mobile SDK

[![Cocoapods](https://img.shields.io/cocoapods/v/CoinbaseWalletSDK)](https://cocoapods.org/pods/CoinbaseWalletSDK)

Coinbase Wallet Mobile SDK is an open source SDK which allows you to connect your native mobile applications to millions of Coinbase Wallet users.

## Install

The Coinbase Wallet Mobile SDK is available on both [CocoaPods](https://cocoapods.org/) and [Swift Package Manager](https://swift.org/package-manager).

### Cocoapods

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

### Swift Package Manager

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

## Usage

### Setup

Coinbase Wallet Mobile SDK uses Universal Links to communicate between Coinbase Wallet and your application.

Before the SDK can be used, it needs to be configured with a Universal Link to your application. This callback URL will be used by the Coinbase Wallet application to navigate back to your application.

```swift
CoinbaseWalletSDK.configure(
    callback: URL(string: "https://myappxyz.com/mycallback")!
)
```

When your application receives a response from Coinbase Wallet via a Universal Link, this URL needs to be handed off to the SDK via the handleResponse function.

```swift
func application(_ app: UIApplication, open url: URL ...) -> Bool {
    if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
        return true
    }
    // handle other types of deep links
    return false
}
```

It’s recommended to place this configuration logic in the AppDelegate as shown in this [example](ios/example/SampleClient/AppDelegate.swift#L19).

### Establishing a connection

A connection to Coinbase Wallet can be initiated by calling the `initiateHandshake` function provided by the SDK. The function also takes in an optional `initialActions` parameter which apps can use to take certain actions along with the initial handshake request.

```swift
private let cbwallet = CoinbaseWalletSDK.shared

cbwallet.initiateHandshake(
    initialActions: [
        Action(jsonRpc: .eth_requestAccounts)
    ]
) { result, account in
    switch result {
    case .success(let response):
        self.logObject(label: "Response:\n", response)

        guard let account = account else { return }
        self.logObject(label: "Account:\n", account)
        self.address = account.address
    case .failure(let error):
        self.log("\(error)")
    }
    self.updateSessionStatus()
}
```

An example handshake request is provided in the sample [application](ios/example/SampleClient/ViewController.swift#L63).

### Making requests

Requests to Coinbase Wallet can be made by calling the `makeRequest` function provided by the SDK. This function also accepts a list of `actions` that can be taken in as a single batch request.

```swift
cbwallet.makeRequest(
    Request(actions: [
        Action(jsonRpc: .eth_signTypedData_v3(
            address: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            message: Data()))
    ])
) { result in
    self.log("\(result)")
}
```

An example request is provided in the sample [application](https://github.com/coinbase/coinbase-wallet-sdk/blob/master/examples/native-sdk-ios-client/SampleApp/ViewController.swift#L29).

For more information on the types of requests you can make, visit our [developer documentation](https://docs.cloud.coinbase.com/wallet-sdk/docs/mobile-sdk-overview).

## References
- Coinbase Wallet [Developer Documentation](https://docs.cloud.coinbase.com/wallet-sdk/docs)
- Questions? Visit our [Developer Forums](https://forums.coinbasecloud.dev/).
- For bugs, please report an issue on Github.

## License

```
Copyright © 2022 Coinbase, Inc. <https://www.coinbase.com/>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
