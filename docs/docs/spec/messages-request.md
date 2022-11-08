# Request content

Request message has `request` as its `content`, which contains following:

## Properties

### `actions`
Array of actions. More details on [batch requests](batch).

### `account`
Optional property to specify the chain, network id, and/or address to run the `action`s. More details on [multi-chain](multi-chain).

## Example
```json
{
  "version": "1.0.3",
  "sender": "AD6aqQNPr4/NRQymzqr14qjlnO9LN5JaEs/XEwEGTno=",
  "content": {
    "request": {
      "actions": [
        {
          "paramsJson": "{\"message\":\"message\",\"address\":\"\"}",
          "method": "personal_sign",
          "optional": true
        }
      ],
      "account": {
        "chain": "eth",
        "networkId": 137,
        "address": ""
      }
    }
  },
  "timestamp": 689618032.540427,
  "callbackUrl": "myappxyz://mycallback/wsegue",
  "uuid": "B454B12D-516D-4CDF-979F-B3B50C956DFC"
}
```