import 'dart:convert';

import 'package:coinbase_wallet_sdk_flutter/action.dart';
import 'package:coinbase_wallet_sdk_flutter/coinbase_wallet_sdk_flutter_platform_interface.dart';
import 'package:coinbase_wallet_sdk_flutter/configuration.dart';
import 'package:coinbase_wallet_sdk_flutter/request.dart';
import 'package:coinbase_wallet_sdk_flutter/return_value.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class CoinbaseWalletSDK {
  static const CoinbaseWalletSDK shared = CoinbaseWalletSDK._();

  const CoinbaseWalletSDK._();

  /// Setup the SDK
  Future<void> configure(Configuration configuration) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _configureIOS(configuration.ios);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await _configureAndroid(configuration.android);
    } else {
      throw UnsupportedError(
        'Unsupported platform: ${defaultTargetPlatform.toString()}',
      );
    }
  }

  /// Initiate the handshake with Coinbase Wallet app
  Future<List<ReturnValue>> initiateHandshake(
    List<Action>? initialActions,
  ) async {
    final actionsJson =
        (initialActions ?? []).map((action) => action.toJson()).toList();

    final result = await CoinbaseWalletSdkFlutterPlatform.instance
        .call('initiateHandshake', jsonEncode(actionsJson));

    return (result ?? [])
        .map((action) => ReturnValue.fromJson(action))
        .cast<ReturnValue>()
        .toList();
  }

  /// Send a web3 request to Coinbase Wallet app
  Future<List<ReturnValue>> makeRequest(Request request) async {
    final result = await CoinbaseWalletSdkFlutterPlatform.instance
        .call('makeRequest', jsonEncode(request.toJson()));

    return (result ?? [])
        .map((action) => ReturnValue.fromJson(action))
        .cast<ReturnValue>()
        .toList();
  }

  /// Disconnect any active session
  Future<void> resetSession() async {
    await CoinbaseWalletSdkFlutterPlatform.instance.call('resetSession');
  }

  /// Check whether CoinbaseWallet app is installed
  Future<bool> isAppInstalled() async {
    final result = await CoinbaseWalletSdkFlutterPlatform.instance
        .call('isAppInstalled');
    return result ?? false;
  }

  // private helper methods

  Future<void> _configureIOS(IOSConfiguration? configuration) async {
    if (configuration == null) {
      throw ArgumentError('iOS configuration is missing.');
    }
    await CoinbaseWalletSdkFlutterPlatform.instance
        .call('configure', configuration.toJson());
  }

  Future<void> _configureAndroid(AndroidConfiguration? configuration) async {
    if (configuration == null) {
      throw ArgumentError('Android configuration is missing.');
    }
    await CoinbaseWalletSdkFlutterPlatform.instance
        .call('configure', configuration.toJson());
  }
}
