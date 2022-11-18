# Batch requests

To improve UX by minimizing app switches, 
MWP allows client apps to make requests with multiple actions at once. 
Wallets should return results in a single response message as well.
Client can specify whether each action is required or optional to customize the flow.

## `Request` has `action`s
- A `request` message contains an array of `action`s
- Each `action` defines a single JSON RPC call with corresponding parameters in JSON format
- `optional` boolean property to tell the host wallet to cancel the request if it fails to process non-optional action.

### Example request message with three actions batched
```json
{
  "version": "1.0.3",
  "sender": "AD6aqQNPr4/NRQymzqr14qjlnO9LN5JaEs/XEwEGTno=",
  "content": {
    "request": {
      "actions": [
        {
          "paramsJson": "{\"chainId\":\"137\"}",
          "method": "wallet_switchEthereumChain",
          "optional": false
        },
        {
          "paramsJson": "{\"address\":\"0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6\",\"message\":\"message\"}",
          "method": "personal_sign",
          "optional": true
        },
        {
          "paramsJson": "{\"toAddress\":\"0\",\"fromAddress\":\"0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6\",\"chainId\":\"137\",\"weiValue\":\"0\",\"data\":\"\"}",
          "method": "eth_sendTransaction",
          "optional": false
        }
      ]
    }
  },
  "timestamp": 689616588.09238,
  "callbackUrl": "myappxyz://mycallback/wsegue",
  "uuid": "84920218-ED92-4DF7-83BC-3CBFD1E5C7E3"
}
```

## `Response` has `value`s

- A `response` message contains array of `value`s
- `value` can be either
    - `result`: JSON string
    - `error`: error code and message

### Example

coming soon
