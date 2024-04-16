---
title: "Establishing a connection"
slug: "ios-establishing-a-connection"
category: "633d1d37bc7103008654c123"
---

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

An example handshake request is provided in our [sample application](https://github.com/coinbase/wallet-mobile-sdk/blob/master/ios/example/SampleClient/ViewController.swift#L63).