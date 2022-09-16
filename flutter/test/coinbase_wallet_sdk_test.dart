import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk_method_channel.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// class MockCoinbaseWalletSdkFlutterPlatform
//     with MockPlatformInterfaceMixin
//     implements CoinbaseWalletSdkFlutterPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');

//   @override
//   Future<String> initiateHandshake() async {
//     return _addy;
//   }

//   @override
//   Future<String> personalSign(String address, String message) async {
//     if (address == _addy) {
//       return '0x0';
//     } else {
//       throw PlatformError(1, 'Invalid address');
//     }
//   }
// }

void main() {
  final CoinbaseWalletSdkFlutterPlatform initialPlatform =
      CoinbaseWalletSdkFlutterPlatform.instance;

  test('$MethodChannelCoinbaseWalletSdkFlutter is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelCoinbaseWalletSdkFlutter>());
  });

  test('getPlatformVersion', () async {
    // CoinbaseWalletSdkFlutter coinbaseWalletSdkFlutterPlugin =
    //     CoinbaseWalletSdkFlutter();
    // MockCoinbaseWalletSdkFlutterPlatform fakePlatform =
    //     MockCoinbaseWalletSdkFlutterPlatform();
    // CoinbaseWalletSdkFlutterPlatform.instance = fakePlatform;

    // expect(await coinbaseWalletSdkFlutterPlugin.getPlatformVersion(), '42');
  });
}
