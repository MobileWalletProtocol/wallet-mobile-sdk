---
title: "API Reference"
slug: "android-api-reference"
category: "633d1d37bc7103008654c123"
---

# Actions

The `initiateHandshake` and `makeRequest` methods accept a list of actions to perform. An `Action` can be created using the `Web3JsonRPC` class.

Below is a list of supported actions for each method:

| Action | RPC method | initiateHandshake | makeRequest |
| :--- | :--- | :--- | :--- |
| [RequestAccounts](doc:android-api-reference#requestaccounts) | [eth_requestAccounts](https://eips.ethereum.org/EIPS/eip-1102) | ✔️ Supported | ✔️ Supported |
| [SignTransaction](doc:android-api-reference#signtransaction) | [eth_signTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_signtransaction) | ❌ Not supported | ✔️ Supported |
| [SendTransaction](doc:android-api-reference#sendtransaction) | [eth_sendTransaction](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sendtransaction) | ❌ Not supported | ✔️ Supported |
| - | [eth_sign](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_sign) | ❌ Not supported | ❌ Not supported |
| [PersonalSign](doc:android-api-reference#personalsign) | [personal_sign](https://eips.ethereum.org/EIPS/eip-191) | ✔️ Supported | ✔️ Supported |
| [SignTypedDataV3](doc:android-api-reference#signtypeddatav3) | [eth_signTypedData_v3](https://eips.ethereum.org/EIPS/eip-712) | ✔️ Supported | ✔️ Supported |
| [SignTypedDataV4](doc:android-api-reference#signtypeddatav4) | [eth_signTypedData_v4](https://eips.ethereum.org/EIPS/eip-712) | ✔️ Supported | ✔️ Supported |
| [SwitchEthereumChain](doc:android-api-reference#switchethereumchain) | [wallet_switchEthereumChain](https://eips.ethereum.org/EIPS/eip-3326) | ✔️ Supported | ✔️ Supported |
| [AddEthereumChain](doc:android-api-reference#addethereumchain) | [wallet_addEthereumChain](https://eips.ethereum.org/EIPS/eip-3085) | ✔️ Supported | ✔️ Supported |
| [WatchAsset](doc:android-api-reference#watchasset) | [wallet_watchAsset](https://eips.ethereum.org/EIPS/eip-747) | ✔️ Supported | ✔️ Supported |

## RequestAccounts

Request that the user provides an account in the form of an Ethereum address.

### Parameters

None.

### Example

```kotlin Kotlin
val requestAccounts = Web3JsonRPC.RequestAccounts().action()
```
```java Java
Action requestAccounts = new Web3JsonRPC.RequestAccounts().action(false);
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

```kotlin Kotlin
val personalSign = Web3JsonRPC.PersonalSign(
   address = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
   message = "0xdeadbeaf"
).action()
```
```java Java
Action personalSign = new Web3JsonRPC.PersonalSign(
       "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
       "0xdeadbeaf")
       .action(false);
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

```kotlin Kotlin
val signTypedDataV3 = Web3JsonRPC.SignTypedDataV3(
   address = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
   typedDataJson = typedData
).action()
```
```java Java
Action signTypedDataV3 = new Web3JsonRPC.SignTypedDataV3(
       "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
       typedData)
       .action(false);
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

```kotlin Kotlin
val signTypedDataV4 = Web3JsonRPC.SignTypedDataV4(
   address = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
   typedDataJson = typedData
).action()
```
```java Java
Action signTypedDataV4 = new Web3JsonRPC.SignTypedDataV4(
       "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
       typedData)
       .action(false);
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

```kotlin Kotlin
val signTransaction = Web3JsonRPC.SignTransaction(
   fromAddress = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
   toAddress = "0x000000000000000000000000000000000000dEaD",
   weiValue = "10000000000000",
   data = "0x",
   nonce = 1,
   gasPriceInWei = "30000000000",
   maxFeePerGas = "60000000000",
   maxPriorityFeePerGas = "2500000000",
   gasLimit = "1000",
   chainId = "1"
).action()
```
```java Java
Action signTransaction = new Web3JsonRPC.SignTransaction(
       "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", // fromAddress
       "0x000000000000000000000000000000000000dEaD", // toAddress
       "10000000000000", // weiValue
       "0x", // data
       1, // nonce
       "30000000000", // gasPriceInWei
       "60000000000", // maxFeePerGas
       "2500000000", // maxPriorityFeePerGas
       "1000", // gasLimit
       "1") // chainId
       .action(false);
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

```kotlin Kotlin
val sendTransaction = Web3JsonRPC.SendTransaction(
   fromAddress = "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826",
   toAddress = "0x000000000000000000000000000000000000dEaD",
   weiValue = "10000000000000",
   data = "0x",
   nonce = 1,
   gasPriceInWei = "30000000000",
   maxFeePerGas = "60000000000",
   maxPriorityFeePerGas = "2500000000",
   gasLimit = "1000",
   chainId = "1"
).action()
```
```java Java
Action sendTransaction = new Web3JsonRPC.SendTransaction(
       "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826", // fromAddress
       "0x000000000000000000000000000000000000dEaD", // toAddress
       "10000000000000", // weiValue
       "0x", // data
       1, // nonce
       "30000000000", // gasPriceInWei
       "60000000000", // maxFeePerGas
       "2500000000", // maxPriorityFeePerGas
       "1000", // gasLimit
       "1") // chainId
       .action(false);
```

## SwitchEthereumChain

Switch a wallet’s currently active chain.

See [wallet_switchEthereumChain](https://eips.ethereum.org/EIPS/eip-3326).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| chainId | `String` | ID of the chain to switch to, as an integer string. |

### Example

```kotlin Kotlin
val switchEthereumChain = Web3JsonRPC.SwitchEthereumChain(
   chainId = "1666600000"
).action()
```
```java Java
Action switchEthereumChain = new Web3JsonRPC.SwitchEthereumChain(
       "1666600000") // chainId
       .action(false);
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
| nativeCurrency | [`AddChainNativeCurrency`](doc:android-api-reference#addchainnativecurrency) | **Optional**. Data for the chain’s native currency. |
| rpcUrls | `List<String>` | List of RPC URL strings. Defaults to an empty list. |

### Example

```kotlin Kotlin
val addEthereumChain = Web3JsonRPC.AddEthereumChain(
   chainId = "1666600000",
   blockExplorerUrls = listOf("https://explorer.harmony.one"),
   chainName = "Harmony Mainnet",
   iconUrls = listOf("https://harmonynews.one/wp-content/uploads/2019/11/slfdjs.png"),
   nativeCurrency = AddChainNativeCurrency("ONE", "ONE", 18)
).action()
```
```java Java
Action addEthereumChain = new Web3JsonRPC.AddEthereumChain(
       "1666600000", // chainId
       List.of("https://explorer.harmony.one"), // blockExplorerUrls
       "Harmony Mainnet", // chainName
       List.of("https://harmonynews.one/wp-content/uploads/2019/11/slfdjs.png"), // iconUrls
       new AddChainNativeCurrency("ONE", "ONE", 18)) // nativeCurrency
       .action(false);
```

## WatchAsset

Add and track a new asset within a wallet.

See [wallet_watchAsset](https://eips.ethereum.org/EIPS/eip-747).

### Parameters

| Name | Type | Description |
| :--- | :--- | :--- |
| type | `String` | Type of token asset. (i.e. `ERC20`, `ERC721`). |
| options | [`WatchAssetOptions`](doc:android-api-reference#watchassetoptions) | Data of the asset to watch (i.e. contract address, name, icon, etc.) |

### Example

```kotlin Kotlin
val watchAsset = Web3JsonRPC.WatchAsset(
   type = "ERC20",
   options = WatchAssetOptions(
      "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a",
      "WONE",
      18,
      "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png"
   )
).action()
```
```java Java
Action watchAsset = new Web3JsonRPC.WatchAsset(
       "ERC20", // type
       new WatchAssetOptions( // options
               "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a", // address
               "WONE", // symbol
               18, // decimals
               "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png") // image
       ).action(false);
```

# Types

## AddChainNativeCurrency

Defines a native currency to add when making a request to add a new Ethereum chain.

See [AddEthereumChain](doc:android-api-reference#addethereumchain).

### Properties

| Name | Type | Description |
| :--- | :--- | :--- |
| name | `String` | Name of native currency for the chain. |
| symbol | `String` | Symbol of native currency for the chain. |
| decimals | `Int` | Decimals of precision, as an integer. |

### Example

```kotlin Kotlin
val nativeCurrency = AddChainNativeCurrency("ONE", "ONE", 18)
```
```java Java
AddChainNativeCurrency nativeCurrency = new AddChainNativeCurrency("ONE", "ONE", 18);
```

## WatchAssetOptions

Defines options when making a request to watch a new asset.

See [WatchAsset](doc:android-api-reference#watchasset).

### Properties

| Name | Type | Description |
| :--- | :--- | :--- |
| address | `String` | Contract address for the token asset. |
| symbol | `String` | **Optional**. Symbol for the token asset. |
| decimals | `Int` | **Optional**. Decimals of precision, as an integer. |
| image | `String` | **Optional**. Logo image for the token asset. |

### Example

```kotlin Kotlin
val watchAssetOptions = WatchAssetOptions(
      address = "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a",
      symbol = "WONE",
      decimals = 18,
      image = "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png"
   )

```
```java Java
WatchAssetOptions watchAssetOptions = new WatchAssetOptions(
        "0xcf664087a5bb0237a0bad6742852ec6c8d69a27a", // address
        "WONE", // symbol
        18, // decimals
        "https://s2.coinmarketcap.com/static/img/coins/64x64/11696.png") // image
       );
```
