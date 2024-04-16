# Messages

Communications between client and server (wallet host) in MWP are through exchanging discrete stateless messages.

The messages sent by the client app are called requests and the ones returned by the wallet host are called responses.

## Forms

MWP messages can be transformed between two forms according to their use cases.

### Data form 

JSON object or corresponding data type in the language in use (e.g. Swift `struct`, Kotlin `data class`, or JavaScript object) for internal usage within the app

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

Deep link URL specifying recipient's address and base64 encoded [JSON object](#data-form) as query parameter to send the data to other party

`https://wallet.coinbase.com/wsegue?p=eyJ2ZXJzaW...U2RTMyQiJ9`


## Properties

### `uuid`
Unique id of the message

### `sender` 
Public key of the sender in base64 encoded string

### `content`
[Message's content](encryption#message-encryption) which might be encrypted by the sender using the derived shared secret

### `timestamp`
UNIX millisecond timestamp

### `version`
Version of the protocol used by the sender

### `callback`
(Optional) sender's callback URL
