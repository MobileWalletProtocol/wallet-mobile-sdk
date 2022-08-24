import 'package:coinbase_wallet_sdk_flutter/coinbase_wallet_sdk_flutter_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MethodChannelCoinbaseWalletSdkFlutter platform =
      MethodChannelCoinbaseWalletSdkFlutter();
  const MethodChannel channel = MethodChannel('coinbase_wallet_sdk_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await platform.getPlatformVersion(), '42');
  });
}
