---
title: "Making requests"
slug: "android-making-requests"
category: "633d1d37bc7103008654c123"
---

Requests to Coinbase Wallet can be made by calling the `makeRequest` function provided by the SDK. This function also accepts a list of actions that can be taken in as a single batch request.

```kotlin Kotlin
val signTypedDataV3 = Web3JsonRPC.SignTypedDataV3(
   "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", // address
   "" // typed data JSON
).action()
val requestActions = listOf(signTypedDataV3)

client.makeRequest(request = RequestContent.Request(actions = requestActions)) { result ->
   result.fold(
       onSuccess = { returnValues ->
           returnValues.handleSuccess("Request", requestActions)
       },
       onFailure = { err ->
           err.handleError("Request")
       }
   )
}
```