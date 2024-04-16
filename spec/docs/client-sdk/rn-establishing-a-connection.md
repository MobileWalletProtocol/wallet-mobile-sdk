---
title: "Establishing a connection"
slug: "rn-establishing-a-connection"
category: "633d1d37bc7103008654c123"
---

A connection to Coinbase Wallet can be initiated using the provided [EIP-1193](https://eips.ethereum.org/EIPS/eip-1193) compliant provider exported by the Mobile SDK. Making an `eth_requestAccounts` request using the provider will automatically initiate a handshake request with Coinbase Wallet.

```javascript
import { WalletMobileSDKEVMProvider } from "@coinbase/wallet-mobile-sdk/build/WalletMobileSDKEVMProvider";

const provider = new WalletMobileSDKEVMProvider({
  jsonRpcUrl: JSON_RPC_URL,
});

const [address] = await provider.request({
  method: "eth_requestAccounts",
  params: [],
});
```
