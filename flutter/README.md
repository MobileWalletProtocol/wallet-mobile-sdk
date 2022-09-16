# coinbase_wallet_sdk

A flutter wrapper for CoinbaseWallet mobile SDK

Note: This wrapper only supports iOS and Android.

## Getting Started

```dart
  import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';

  // Configure SDK for each platform
  await CoinbaseWalletSDK.shared.configure(
    Configuration(
      ios: IOSConfiguration(
        host: Uri.parse('https://wallet.coinbase.com/wsegue'),
        callback: Uri.parse('tribesxyz://mycallback'),
      ),
      android: AndroidConfiguration(
        domain: Uri.parse('https://www.myappxyz.com'),
      ),
    ),
  );
```

### iOS only

```swift
    override func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        if (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        // handle other types of deep links
        return false
    }

    override func application(
      _ application: UIApplication,
      continue userActivity: NSUserActivity,
      restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        if let url = userActivity.webpageURL,
           (try? CoinbaseWalletSDK.shared.handleResponse(url)) == true {
            return true
        }
        // handle other types of deep links
        return false
    }
```

## Usage

```dart
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
