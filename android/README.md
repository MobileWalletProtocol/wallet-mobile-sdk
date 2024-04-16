# Coinbase Wallet Mobile SDK

[![Maven](https://img.shields.io/maven-central/v/com.coinbase/coinbase-wallet-sdk?label=maven)](https://mavenlibs.com/maven/dependency/com.coinbase/coinbase-wallet-sdk)

Coinbase Wallet Mobile SDK is an open source SDK which allows you to connect your native mobile applications to millions of Coinbase Wallet users.

## Install

The Coinbase Wallet Mobile SDK is available on [Maven Central](https://search.maven.org/artifact/com.coinbase/coinbase-wallet-sdk/0.1.0/aar).

### Gradle

Add Coinbase Wallet SDK to your `build.gradle` file.

```groovy
repositories {
   mavenCentral()
}

dependencies {
   implementation "com.coinbase:coinbase-wallet-sdk:1.0.3"
}
```

### Maven

Add Coinbase Wallet SDK to your `pom.xml` file.

```xml
<dependency>
	<groupId>com.coinbase</groupId>
	<artifactId>coinbase-wallet-sdk</artifactId>
	<version>1.0.3</version>
</dependency>
```

## Usage

### Setup

In order for your app to interact with Coinbase Wallet, you must add a [queries element](https://developer.android.com/guide/topics/manifest/queries-element) to your `AndroidManifest.xml` file, specifying the package name for Coinbase Wallet, `org.toshi`.

```xml
    <queries>
        <package android:name="org.toshi" />
    </queries>
```

Before the SDK can be used, it needs to be configured with an App Link to your application. This callback URL will be used by the Coinbase Wallet application to navigate back to your application.

```kotlin
CoinbaseWalletSDK(
    appContext = applicationContext,
    domain = Uri.parse("https://www.myappxyz.com"),
    openIntent = { intent -> launcher.launch(intent) }
)
```

When your application receives a response from Coinbase Wallet via App Links, this URL needs to be handed off to the SDK via the handleResponse function.

```kotlin
launcher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
   val uri = result.data?.data ?: return@registerForActivityResult
   client.handleResponse(uri)
}
```

An example is provided in the sample [application](android/example/src/main/java/com/coinbase/android/beta/MainActivity.kt#L27).

### Establishing a connection

A connection to Coinbase Wallet can be initiated by calling the `initiateHandshake` function provided by the SDK. The function also takes in an optional `initialActions` parameter which apps can use to take certain actions along with the initial handshake request.

```kotlin
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

An example handshake request is provided in the sample [application](android/example/src/main/java/com/coinbase/android/beta/MainActivity.kt#L52).

### Making requests

Requests to Coinbase Wallet can be made by calling the `makeRequest` function provided by the SDK. This function also accepts a list of `actions` that can be taken in as a single batch request.

```kotlin
val signTypedDataV3 = Web3JsonRPC.SignTypedDataV3(
   "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", // address
   typedDataJson // typed data JSON
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

An example request is provided in the sample [application](android/example/src/main/java/com/coinbase/android/beta/MainActivity.kt#L68).

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
