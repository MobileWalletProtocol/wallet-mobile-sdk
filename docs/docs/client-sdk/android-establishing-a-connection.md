---
title: "Establishing a connection"
slug: "android-establishing-a-connection"
category: "633d1d37bc7103008654c123"
---

A connection to Coinbase Wallet can be initiated by calling the `initiateHandshake` function provided by the SDK. The function also takes in an optional `initialActions` parameter which apps can use to take certain actions along with the initial handshake request.

```kotlin Kotlin
val requestAccount = Web3JsonRPC.RequestAccounts().action()
val handShakeActions = listOf(requestAccount)

client.initiateHandshake(
   initialActions = handShakeActions
) { result: Result<List<ActionResult>>, account: Account? ->
    result.onSuccess { actionResults: List<ActionResult> ->
        actionResults.handleSuccess("Handshake", handShakeActions, account)
    }
    result.onFailure { err ->
        err.handleError("HandShake")
    }
}
```
```java Java
// requestAccounts request
ArrayList<Action> actions = new ArrayList<>();
actions.add(
   new Web3JsonRPC.RequestAccounts().action(false)
);

// Initiate handshake
client.initiateHandshake(
   actions,
   (results, account) -> {
      for (ActionResult result : results) {
         if (result instanceof ActionResult.Result) {
            ((ActionResult.Result) result).getValue();
         }

         if (result instanceof ActionResult.Error) {
            ((ActionResult.Error) result).getCode();
            ((ActionResult.Error) result).getMessage();
         }
      }
   },
   error -> {
   }
);
```

An example handshake request is provided in the [sample application](https://github.com/coinbase/wallet-mobile-sdk/blob/master/android/example/src/main/java/com/coinbase/android/beta/MainActivity.kt#L52).