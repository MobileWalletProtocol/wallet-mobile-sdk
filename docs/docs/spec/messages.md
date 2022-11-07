# Messages

Communications between client and server (wallet host) in MWP are through exchanging discrete stateless messages.

The messages sent by the client app are called requests and the ones returned by the wallet host are called responses.

## Forms

MWP messages can be transformed between two types according to their use cases.

### Data form

JSON object or corresponding data type in the language in use (e.g. Swift `struct`, Kotlin `data class`, or JavaScript object)

```json
{
  "uuid" : "634A5C15-0316-4FD1-86FB-4818DBD6C12D",
  "sender" : "bwf9U+VbjmvfBr3p3aoJyOEKS6mq7sSrg56V6FDYMBs=",
  "content" : {...},
  "version" : "1.0.0",
  "timestamp" : "1667475279"
}
```

### URL form

Deep link URL specifying recipient's address and base64 encoded [JSON object](#data-form) as query parameter

`https://wallet.coinbase.com/wsegue?p=eyJ2ZXJzaW...U2RTMyQiJ9`


## Properties

### `uuid`
Unique id of the message

### `sender` 
Public key of the sender in base64 encoded string

### `content`
[Message's content](#contents) which might be encrypted by the sender using the derived shared secret

### `timestamp`
UNIX millisecond timestamp

### `version`
Version of the protocol used by the sender

### `callback`
(Optional) sender's callback URL


## Contents

Each `Message` contains its `content`. 

By default, the content data are encrypted using the shared secret exchanged between the sender and receiver, so that it can be read only by the peers.

However, there are two exceptions where the content data are not encrypted:
1. Handshake calls from the client in order to exchange keys with the wallet
2. Failure responses from wallet to return errors happening during the handshake processes
