# Background

- To use mobile wallets with dapps, communication solutions like WalletLink or WalletConnect have been used, which require bridge servers to pass on dapp’s requests and user’s responses. 
- These protocols were originally designed to deliver messages between entities located on different devices (desktop browser and user’s mobile).
- For mobile use cases, where both app and wallet are within a single device, repurposing the existing solutions would be inefficient and moreover introduce reliability issues as they rely on a connection to an external server via web sockets.
