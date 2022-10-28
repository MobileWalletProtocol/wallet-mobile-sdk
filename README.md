# Mobile Wallet Protocol (MWP)

MWP is a protocol to allow mobile web3 apps to interact with wallet apps and access users' web3 accounts. 
It provides an encrypted P2P communication channel between client and server (wallet host) to exchange discrete stateless messages.
The messages sent by the client app are called requests and the ones returned by the wallet host are called responses.
The protocol uses deep links as its transport layer to let participating apps deliver messages directly to their peer without external entities such as a bridge server.
It defines a decentralized verification procedure to check authenticity of each other using well-known data for univeral link without a centralized registry.

## Background

![](https://images.ctfassets.net/c5bd0wqjc7v0/2L8Padm8D0FqNrgkE7lUDh/7460be599006828b8f803e8d4d4ee424/image4.png)

- To use mobile wallets with dapps, communication solutions like WalletLink or WalletConnect have been used, which require bridge servers to pass on dapp’s requests and user’s responses. 
- These protocols were originally designed to deliver messages between entities located on different devices (desktop browser and user’s mobile).
- For mobile use cases, where both app and wallet are within a single device, repurposing the existing solutions would be inefficient and moreover introduce reliability issues as they rely on a connection to an external server via web sockets.

## Network layer

Deep linking through universal links on iOS and app links on Android.
(Intent on android.)

## Request-Response model

## Message format

## Encryption

## Authentication

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
