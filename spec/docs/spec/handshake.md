# Handshake

For key exchange, client apps make `handshake` calls to ask wallets to generate and share a key to encrypt subsequent messages on the session.

## Handshake request message from client

`content` of a handshake message contains following:

### `appId`
Bundle ID (iOS) or application/package ID (Android). 
e.g. "com.coinbase.SampleClient"

### `callback`
Sender's URL to receive response from receiver.
For the best security measure, [universal links](https://developer.apple.com/ios/universal-links/) (or [app links](https://developer.android.com/training/app-links)) are recommended.

### `initialActions`
(optional) Actions to request after successful handshake process.
e.g. `eth_requestAccounts` to get user's eth account info along with the handshake response

### Example request message
```json
{
  "version": "1.0.3",
  "sender": "lEC/X3K68rlgOoldMdk0D77738Y7W0mDbMMV5R6VyCE=",
  "content": {
    "handshake": {
      "appId": "com.coinbase.SampleClient",
      "callback": "myappxyz://mycallback/wsegue",
      "initialActions": [
        {
          "paramsJson": "{}",
          "method": "eth_requestAccounts",
          "optional": false
        }
      ]
    }
  },
  "timestamp": 689587969.289106,
  "callbackUrl": "myappxyz://mycallback/wsegue",
  "uuid": "451711FA-96B6-4955-B6EA-EFA78CEB89F5"
}
```

## Response from wallet

Once the host wallet [verifies the client app](verification) and gets approval from the user,
it generates a key pair for the session and shares it with the caller.

### Example response message (success)
```json
{
  "version": "1.0.3",
  "sender": "EnX8x2D6lHzTg8YZCLybHPwivbCBRyFlP8aA235+MBg=",
  "content": {
    "response": {
      "requestId": "5A920962-ECBE-42BC-A956-83A56F0D52F8",
      "values": [
        {
          "result": {
            "value": "{\"chain\":\"eth\",\"networkId\":1,\"address\":\"0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6\"}"
          }
        }
      ]
    }
  },
  "timestamp": 689615011.030334,
  "uuid": "7446663A-685A-47E5-89E3-C1D37F085330"
}
```

### Example response message (failure)
```json
{
  "version": "1.0.3",
  "sender": "lEC/X3K68rlgOoldMdk0D77738Y7W0mDbMMV5R6VyCE=",
  "content": {
    "failure": {
      "requestId": "B78F510E-DD5C-4477-8350-7550FAC7452E",
      "description": "Request denied"
    }
  },
  "timestamp": 689611333.369556,
  "uuid": "E485820B-8F5E-4F8C-9A00-CE5B5B9C6F35"
}
```
