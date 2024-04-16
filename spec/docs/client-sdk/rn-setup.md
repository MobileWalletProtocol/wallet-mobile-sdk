---
title: "Setup"
slug: "rn-setup"
category: "633d1d37bc7103008654c123"
---

## iOS Setup

Coinbase Wallet Mobile SDK uses [Universal Links](https://developer.apple.com/ios/universal-links/) to communicate between Coinbase Wallet and your application.

## Android Setup

In order for your app to interact with Coinbase Wallet, you must add a [queries element](https://developer.android.com/guide/topics/manifest/queries-element) to your `AndroidManifest.xml` file, specifying the package name for Coinbase Wallet, `org.toshi`.

```xml AndroidManifest.xml
<queries>
      <package android:name="org.toshi" />
</queries>
```

## Configuration

Before the SDK can be used, it needs to be configured with the following parameters.

**callbackURL (iOS):** The Universal Link used by Coinbase Wallet to return responses to your application.

**hostURL (iOS):** The Universal Link used by the Mobile SDK to open the wallet application.

**hostPackageName (Android):** The package name of the wallet application.

```javascript
import { configure } from "@coinbase/wallet-mobile-sdk";

configure({
  callbackURL: new URL("https://myappxyz.com/wsegue"),
  hostURL: new URL("https://wallet.coinbase.com/wsegue"),
  hostPackageName: "org.toshi",
});
```

## Listening for responses

When your application receives a response from Coinbase Wallet via a Universal Link, this URL needs to be handed off to the SDK via the `handleResponse` function.

```javascript
import { handleResponse } from "@coinbase/wallet-mobile-sdk";

// Your app's deeplink handling code
useEffect(() => {
  const sub = Linking.addEventListener("url", ({ url }) => {
    const handledBySdk = handleResponse(new URL(url));
    if (!handledBySdk) {
      // Handle other deeplinks
    }
  });

  return () => sub.remove();
}, []);
```
