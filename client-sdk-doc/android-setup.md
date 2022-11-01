---
title: "Setup"
slug: "android-setup"
category: "633d1d37bc7103008654c123"
---

In order for your app to interact with Coinbase Wallet, you must add a [queries element](https://developer.android.com/guide/topics/manifest/queries-element) to your `AndroidManifest.xml` file, specifying the package name for Coinbase Wallet, `org.toshi`.

```xml AndroidManifest.xml
<queries>
      <package android:name="org.toshi" />
</queries>
```

Before the SDK can be used, it needs to be configured with an App Link to your application. This callback URL will be used by the Coinbase Wallet application to navigate back to your application.

```kotlin Kotlin
CoinbaseWalletSDK(
    appContext = applicationContext,
    domain = Uri.parse("https://www.myappxyz.com"),
    openIntent = { intent -> launcher.launch(intent) }
)
```
```java Java
new CoinbaseWalletSDK(
    Uri.parse("https://www.myappxyz.com"),
    getApplicationContext(),
    CBW_PACKAGE_NAME,
    intent -> {
        startActivityForResult(intent, CBW_ACTIVITY_RESULT_CODE);
    }
);
```

When your application receives a response from Coinbase Wallet via App Links, this URL needs to be handed off to the SDK via the `handleResponse` function.

```kotlin Kotlin
launcher = registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
   val uri = result.data?.data ?: return@registerForActivityResult
   client.handleResponse(uri)
}
```
```java Java
@Override
protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
   super.onActivityResult(requestCode, resultCode, data);

   if (requestCode != CBW_ACTIVITY_RESULT_CODE) {
       return;
   }

   if (data == null) {
       return;
   }

   Uri url = data.getData();
   client.handleResponse(url);
}
```

An example is provided in our [sample application](https://github.com/coinbase/wallet-mobile-sdk/blob/master/android/example/src/main/java/com/coinbase/android/beta/MainActivity.kt#L27).