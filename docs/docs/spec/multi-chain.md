# Multi-chain support

MWP is chain-agnostic. 
As long as the wallet supports the chain and is able to process the requested actions, apps can communicate using MWP.

## `Account`

MWP defines a dedicated type to specify `account`s.
It contains `chain` and `networkId` along with `address`.

### `chain`
e.g. `"eth"`

### `networkId`
e.g. `1`

### `address`
e.g. `"0x571a6a108adb08f9ca54fe8605280F9EE0eD4AF6"`


## `Request` message with `account`

See [request content properties](messages-request#account).

