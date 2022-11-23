---
title: "Making requests"
slug: "rn-making-requests"
category: "633d1d37bc7103008654c123"
---

Requests to Coinbase Wallet can be made using the exported `WalletMobileSDKEVMProvider`. Supported RPC methods are listed in the [API Reference](./rn-api-reference.md).

```javascript
const provider = new WalletMobileSDKEVMProvider({
  jsonRpcUrl: JSON_RPC_URL,
});

const signature = await provider.request({
  method: "personal_sign",
  params: [
    "0x686f6c61206d756e646f",
    "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
  ],
});
```

An example request is provided in our [sample application](https://github.com/coinbase/wallet-mobile-sdk/blob/b87e05cd936fd873fe4dd2eb79b2dc81aa1be4cf/react-native/client/example/App.js#L82-L95).
