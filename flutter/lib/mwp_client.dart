import 'dart:convert';

import 'package:coinbase_wallet_sdk/account.dart';
import 'package:coinbase_wallet_sdk/action.dart';
import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk_platform_interface.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:coinbase_wallet_sdk/return_value.dart';
import 'package:coinbase_wallet_sdk/wallet.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class MWPClient {
  final Wallet wallet;

  const MWPClient({
      required this.wallet
  });

  /// Setup the SDK
  static Future<void> configure(Configuration configuration) async {
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
  Future<List<ReturnValueWithAccount>> initiateHandshake(
    List<Action>? initialActions,
  ) async {
    final actionsJson =
        (initialActions ?? []).map((action) => action.toJson()).toList();

    final result = await CoinbaseWalletSdkFlutterPlatform.instance.call(
        'initiateHandshake',
        jsonEncode(<String, dynamic>{
          'wallet': wallet.toJson(),
          'argument': actionsJson,
        })
    );

    final returnValuesWithAccounts = (result ?? [])
        .map(
          (e) {
            final map = Map<String, dynamic>.from(e);
            return ReturnValueWithAccount.fromJson(map);
          },
        )
        .cast<ReturnValueWithAccount>()
        .toList();

    return returnValuesWithAccounts;
  }

  /// Send a web3 request to Coinbase Wallet app
  Future<List<ReturnValue>> makeRequest(Request request) async {
    final result = await CoinbaseWalletSdkFlutterPlatform.instance.call(
        'makeRequest',
        jsonEncode(<String, dynamic>{
          'wallet': wallet.toJson(),
          'argument': request.toJson(),
        })
    );

    return (result ?? [])
        .map((e) => ReturnValue.fromJson(e))
        .cast<ReturnValue>()
        .toList();
  }

  /// Disconnect any active session
  Future<void> resetSession() async {
    await CoinbaseWalletSdkFlutterPlatform.instance.call(
        'resetSession',
        jsonEncode(<String, dynamic>{
          'wallet': wallet.toJson(),
          'argument': null,
        })
    );
  }

  // private helper methods

  static Future<void> _configureIOS(IOSConfiguration? configuration) async {
    if (configuration == null) {
      throw ArgumentError('iOS configuration is missing.');
    }
    await CoinbaseWalletSdkFlutterPlatform.instance
        .call('static_configure', configuration.toJson());
  }

  static Future<void> _configureAndroid(AndroidConfiguration? configuration) async {
    if (configuration == null) {
      throw ArgumentError('Android configuration is missing.');
    }
    await CoinbaseWalletSdkFlutterPlatform.instance
        .call('configure', configuration.toJson());
  }

  static Future<List<Wallet>> getWallets() async {
    final result =
        await CoinbaseWalletSdkFlutterPlatform.instance.call('static_getWallets');

    final wallets =
        (result ?? []).map((e) => Wallet.fromJson(e)).cast<Wallet>().toList();
    return wallets;
  }
}

class ReturnValueWithAccount {
  final String? value;
  final ReturnValueError? error;
  final Account? account;

  ReturnValueWithAccount(ReturnValue returnValue, this.account)
      : value = returnValue.value,
        error = returnValue.error;

  factory ReturnValueWithAccount.fromJson(Map<String, dynamic> json) {
    final account = json['account'];
    return ReturnValueWithAccount(
      ReturnValue.fromJson(json),
      account == null
          ? null
          : Account.fromJson(Map<String, dynamic>.from(account)),
    );
  }
}
