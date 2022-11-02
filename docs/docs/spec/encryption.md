# Encryption

- [Diffie–Hellman key exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange)
- client and wallet generate its own key pair for each session and derive shared key with peer’s public key
- For pairing (handshake) process: public key encryption to grant access token visible only to the caller
- After successful handshake: access token itself is the shared key to encrypt all messages between the client and the wallet for secure communication

