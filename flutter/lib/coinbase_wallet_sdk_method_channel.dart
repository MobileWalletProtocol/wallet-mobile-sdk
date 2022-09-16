import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'coinbase_wallet_sdk_platform_interface.dart';

/// An implementation of [CoinbaseWalletSdkFlutterPlatform] that uses method channels.
class MethodChannelCoinbaseWalletSdkFlutter
    extends CoinbaseWalletSdkFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('coinbase_wallet_sdk');

  @override
  Future<dynamic> call(String method, [arguments]) async {
    final result = await methodChannel.invokeMethod<dynamic>(method, arguments);
    if (result is bool) {
      return result;
    }

    return result != null ? jsonDecode(result as String) : null;
  }
}
