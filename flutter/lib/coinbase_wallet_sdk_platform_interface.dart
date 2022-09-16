import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'coinbase_wallet_sdk_method_channel.dart';

abstract class CoinbaseWalletSdkFlutterPlatform extends PlatformInterface {
  /// Constructs a CoinbaseWalletSdkFlutterPlatform.
  CoinbaseWalletSdkFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CoinbaseWalletSdkFlutterPlatform _instance =
      MethodChannelCoinbaseWalletSdkFlutter();

  /// The default instance of [CoinbaseWalletSdkFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelCoinbaseWalletSdkFlutter].
  static CoinbaseWalletSdkFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CoinbaseWalletSdkFlutterPlatform] when
  /// they register themselves.
  static set instance(CoinbaseWalletSdkFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<dynamic> call(String method, [dynamic arguments]);
}

class PlatformError implements Exception {
  final int code;
  final String message;

  PlatformError(this.code, this.message);

  @override
  String toString() {
    return "PlatformError(code: $code, message: $message)";
  }
}

class PlatformResult {
  final String? value;
  final PlatformError? error;

  PlatformResult(this.value, this.error);
}
