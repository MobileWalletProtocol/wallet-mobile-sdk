---
title: "Making requests"
slug: "ios-making-requests"
category: "633d1d37bc7103008654c123"
---

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

An example request is provided in our [sample application](https://github.com/coinbase/coinbase-wallet-sdk/blob/master/examples/native-sdk-ios-client/SampleApp/ViewController.swift#L29).