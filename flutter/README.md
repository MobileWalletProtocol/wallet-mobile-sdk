# coinbase_wallet_sdk_flutter

A flutter wrapper for CoinbaseWallet mobile SDK

Note: This wrapper only supports iOS and Android.

## Getting Started

```dart 
  import 'package:coinbase_wallet_sdk_flutter/coinbase_wallet_sdk.dart';
  
  
  // Configure SDK for each platform
  await CoinbaseWalletSDK.shared.configure(
    Configuration(
      ios: IOSConfiguration(
        host: Uri.parse('cbwallet://wsegue'),
        callback: Uri.parse('tribesxyz://mycallback'),
      ),
      android: AndroidConfiguration(
        domain: Uri.parse('https://www.coinbase.com'),
      ),
    ),
  );
    
  // To call web3's eth_requestAccounts
  final response = await CoinbaseWalletSDK.shared.initiateHandshake([
    const RequestAccounts(),
  ]);
  
  final walletAddress = response[0].value;

  // to call web3's personalSign
  final response = await CoinbaseWalletSDK.shared.makeRequest(
    Request(
      actions: [
        PersonalSign(address: address.value, message: message),
      ],
    ),
  );
  
  final signature = response[0].value;
```


