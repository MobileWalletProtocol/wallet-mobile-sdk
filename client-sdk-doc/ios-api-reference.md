---
title: "API Reference"
slug: "ios-api-reference"
category: "633d1d37bc7103008654c123"
---

# Actions

The `initiateHandshake` and `makeRequest` methods accept a list of actions to perform. An `Action` can be created using the `Web3JsonRPC` class.

Below is a list of supported actions for each method:

| Action | RPC method | initiateHandshake | makeRequest |
| :--- | :--- | :--- | :--- |
| [RequestAccounts](doc:ios-api-reference#requestaccounts) | [eth_requestAccounts](https://eips.ethereum.org/EIPS/eip-1102) | ✔️ Supported | ✔️ Supported |
| [SignTransaction](doc:ios-api-reference#signtransaction) | [eth_signTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_signtransaction) | ❌ Not supported | ✔️ Supported |
| [SendTransaction](doc:ios-api-reference#sendtransaction) | [eth_sendTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sendtransaction) | ❌ Not supported | ✔️ Supported |
| - | [eth_sign](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign) | ❌ Not supported | ❌ Not supported |
| [PersonalSign](doc:ios-api-reference#personalsign) | [personal_sign](https://eips.ethereum.org/EIPS/eip-191) | ✔️ Supported | ✔️ Supported |
| [SignTypedDataV3](doc:ios-api-reference#signtypeddatav3) | [eth_signTypedData_v3](https://eips.ethereum.org/EIPS/eip-712) | ✔️ Supported | ✔️ Supported |
| [SignTypedDataV4](doc:ios-api-reference#signtypeddatav4) | [eth_signTypedData_v4](https://eips.ethereum.org/EIPS/eip-712) | ✔️ Supported | ✔️ Supported |
| [SwitchEthereumChain](doc:ios-api-reference#switchethereumchain) | [wallet_switchEthereumChain](https://eips.ethereum.org/EIPS/eip-3326) | ✔️ Supported | ✔️ Supported |
| [AddEthereumChain](doc:ios-api-reference#addethereumchain) | [wallet_addEthereumChain](https://eips.ethereum.org/EIPS/eip-3085) | ✔️ Supported | ✔️ Supported |
| [WatchAsset](doc:ios-api-reference#watchasset) | [wallet_watchAsset](https://eips.ethereum.org/EIPS/eip-747) | ✔️ Supported | ✔️ Supported |

## RequestAccounts

Request that the user provides an account in the form of an Ethereum address.

### Parameters

None.

### Example

```swift
let requestAccounts = Action(jsonRpc: .eth_requestAccounts)
```

## PersonalSign

Sign a message by calculating an Ethereum specific signature with: `sign(keccak256("\x19Ethereum Signed Message:\n" + len(message) + message))`.

Adding a prefix to the message makes the calculated signature recognisable as an Ethereum specific signature. This prevents misuse where a malicious DApp can sign arbitrary data (e.g. transaction) and use the signature to impersonate the victim.

See [personal_sign](https://eips.ethereum.org/EIPS/eip-191).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| address | `String` | Address to sign data with. |
| message | `String` | Message data to sign. |

### Example

```swift
let personalSign =
      Action(jsonRpc: .personal_sign(
            address: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            message: "0xdeadbeaf"))
```

## SignTypedDataV3

Sign typed structured data.

See [eth_signTypedData_v3](https://eips.ethereum.org/EIPS/eip-712).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| address | `String` | Address to sign data with. |
| typedDataJson | `String` | Typed data to sign. Structured according to the JSON-Schema specified in [EIP-712](https://eips.ethereum.org/EIPS/eip-712). |

### Example

```swift
let signTypedDataV3 =
      Action(jsonRpc: .eth_signTypedData_v3(
            address: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            typedDataJson: JSONString(encode: typedData)!))
```

## SignTypedDataV4

Sign typed structured data.

See [eth_signTypedData_v4](https://eips.ethereum.org/EIPS/eip-712).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| address | `String` | Address to sign data with. |
| typedDataJson | `String` | Typed data to sign. Structured according to the JSON-Schema specified in [EIP-712](https://eips.ethereum.org/EIPS/eip-712). |

### Example

```swift
let signTypedDataV4 =
      Action(jsonRpc: .eth_signTypedData_v4(
            address: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
            typedDataJson: JSONString(encode: typedData)!))
```

## SignTransaction

Sign a transaction that can be submitted to the network at a later time.

See [eth_signTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_signtransaction).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| fromAddress | `String` | Address the transaction is sent from. |
| toAddress | `String` | **Optional**. Address the transaction is sent to. |
| weiValue | `BigInt` | Value for the transaction, in Wei. |
| data | `String` | Compiled code of a contract or the hash of the invoked method signature and encoded parameters. |
| nonce | `Int` | **Optional**. Nonce of the transaction. Allows for overwriting pending transactions that use an identical nonce. |
| gasPriceInWei | `BigInt` | **Optional**. Gas price for the transaction, in Wei. |
| maxFeePerGas | `BigInt` | **Optional**. Maximum fee per unit of gas for the transaction. |
| maxPriorityFeePerGas | `BigInt` | **Optional**. Maximum priority fee per unit of gas for the transaction. |
| gasLimit | `BigInt` | **Optional**. Gas limit for the transaction. |
| chainId | `String` | Chain ID for the transaction, as an integer string. |

### Example

```swift
let signTransaction = 
      Action(jsonRpc: .eth_signTransaction(
             fromAddress: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
             toAddress: "0x000000000000000000000000000000000000dEaD",
             weiValue: "10000000000000",
             data: "0x",
             nonce: 1,
             gasPriceInWei: "30000000000",
             maxFeePerGas: "60000000000",
             maxPriorityFeePerGas: "2500000000",
             gasLimit: "1000",
             chainId: "1"))
```

## SendTransaction

Send a transaction, or create a contract if the `data` field contains code.

See [eth_sendTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sendtransaction).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| fromAddress | `String` | Address the transaction is sent from. |
| toAddress | `String` | **Optional**. Address the transaction is sent to. |
| weiValue | `BigInt` | Value for the transaction, in Wei. |
| data | `String` | Compiled code of a contract or the hash of the invoked method signature and encoded parameters. |
| nonce | `Int` | **Optional**. Nonce of the transaction. Allows for overwriting pending transactions that use an identical nonce. |
| gasPriceInWei | `BigInt` | **Optional**. Gas price for the transaction, in Wei. |
| maxFeePerGas | `BigInt` | **Optional**. Maximum fee per unit of gas for the transaction. |
| maxPriorityFeePerGas | `BigInt` | **Optional**. Maximum priority fee per unit of gas for the transaction. |
| gasLimit | `BigInt` | **Optional**. Gas limit for the transaction. |
| chainId | `String` | Chain ID for the transaction, as an integer string. |

### Example

```swift
let sendTransaction = 
      Action(jsonRpc: .eth_sendTransaction(
             fromAddress: "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
             toAddress: "0x000000000000000000000000000000000000dEaD",
             weiValue: "10000000000000",
             data: "0x",
             nonce: 1,
             gasPriceInWei: "30000000000",
             maxFeePerGas: "60000000000",
             maxPriorityFeePerGas: "2500000000",
             gasLimit: "1000",
             chainId: "1"))
```

## SwitchEthereumChain

Switch a wallet’s currently active chain.

See [wallet_switchEthereumChain](https://eips.ethereum.org/EIPS/eip-3326).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| chainId | `String` | ID of the chain to switch to, as an integer string. |

### Example

```swift
let switchEthereumChain =
      Action(jsonRpc: .wallet_switchEthereumChain(chainId: "1666600000"))
```

## AddEthereumChain

Add a chain to a wallet.

See [wallet_addEthereumChain](https://eips.ethereum.org/EIPS/eip-3085).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| chainId | `String` | ID of the chain to add, as an integer string. |
| blockExplorerUrls | `List<String>` | **Optional**. List of block explorer URL strings. |
| chainName | `String` | **Optional**. Name of the chain to add. |
| iconUrls | `List<String>` | **Optional**. List of image icons URL strings. |
| nativeCurrency | [`AddChainNativeCurrency`](doc:ios-api-reference#addchainnativecurrency) | **Optional**. Data for the chain’s native currency. |
| rpcUrls | `List<String>` | List of RPC URL strings. Defaults to an empty list. |

### Example

```swift
let addEthereumChain = 
      Action(jsonRpc: .wallet_addEthereumChain(
             chainId: "1666600000",
              blockExplorerUrls: ["https://explorer.harmony.one"],
              chainName: "Harmony Mainnet",
              iconUrls: ["https://harmonynews.one/wp-content/uploads/2019/11/slfdjs.png"],
              nativeCurrency: AddChainNativeCurrency(
                    name: "ONE",
                    symbol: "ONE",
                    decimals: 18)
             ))
```

## WatchAsset

Add and track a new asset within a wallet.

See [wallet_watchAsset](https://eips.ethereum.org/EIPS/eip-747).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| type | `String` | Type of token asset. (i.e. `ERC20`, `ERC721`). |
| options | [`WatchAssetOptions`](doc:ios-api-reference#watchassetoptions) | Data of the asset to watch (i.e. contract address, name, icon, etc.) |

### Example

```swift
let watchAsset = 
      Action(jsonRpc: .wallet_watchAsset(
             type: "ERC20",
             options: WatchAssetOptions(
                    address: "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a",
                    symbol: "WONE",
                    decimals: 18,
                    image: "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png")
             ))
```

# Types

## AddChainNativeCurrency

Defines a native currency to add when making a request to add a new Ethereum chain.

See [AddEthereumChain](doc:ios-api-reference#addethereumchain).

### Properties

| Name | Type | Description |
| :--- | :--- | :--- |
| name | `String` | Name of native currency for the chain. |
| symbol | `String` | Symbol of native currency for the chain. |
| decimals | `Int` | Decimals of precision, as an integer. |

### Example

```swift
let nativeCurrency =
      AddChainNativeCurrency(name: "ONE", symbol: "ONE", decimals: 18)
```

## WatchAssetOptions

Defines options when making a request to watch a new asset.

See [WatchAsset](doc:ios-api-reference#watchasset).

### Properties

| Name | Type | Description |
| :--- | :--- | :--- |
| address | `String` | Contract address for the token asset. |
| symbol | `String` | **Optional**. Symbol for the token asset. |
| decimals | `Int` | **Optional**. Decimals of precision, as an integer. |
| image | `String` | **Optional**. Logo image for the token asset. |

### Example

```swift
let watchAssetOptions = WatchAssetOptions(
      address: "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a",
      symbol: "WONE",
      decimals: 18,
      image: "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png")
```
