# Encryption

MWP uses deep links, which isn't inherently secure channel, for direct communication between peers.

To ensure security, all messages in MWP after secure key exchange process are end-to-end encrypted.

## Key generation

Both the client and the wallet generate their own key pair for each session via [Key-agreement protocol](https://en.wikipedia.org/wiki/Key-agreement_protocol) using [Elliptic-curve](https://en.wikipedia.org/wiki/Elliptic-curve_cryptography).

Each peer stores its private key in secure persistent storage
and share its public key with the other party.

## Key exchange to derive shared secret

MWP uses [Diffie–Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange) method to securely share cryptographic keys over deep links.

This method allows the two parties to derive the same shared secret offline using its own private key and the peer's public key.

## Message encryption

After successful [handshake process](/docs/spec/handshake) to exchange keys, subsequent messages are encrypted with the common shared secret using a symmetric-key algorithm.

It uses [AES](https://en.wikipedia.org/wiki/Advanced_Encryption_Standard)-[GCM](https://en.wikipedia.org/wiki/Galois/Counter_Mode) algorithm for cryptographic operations.

Coinbase's SDK is built with 
[Apple CryptoKit](https://developer.apple.com/documentation/cryptokit/) for iOS, 
[Google Tink](https://github.com/google/tink) and [androidx.security](https://developer.android.com/jetpack/androidx/releases/security) for Android.

![](img/diffie-hellman.png)
> source: https://commons.wikimedia.org/wiki/File:Public_key_shared_secret.svg
