import 'dart:async';

import 'package:coinbase_wallet_sdk/coinbase_wallet_sdk.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _addy = "";
  String _signed = "";
  String _sessionCleared = "";

  @override
  void initState() {
    CoinbaseWalletSDK.shared.configure(
      Configuration(
        ios: IOSConfiguration(
          host: Uri.parse('cbwallet://wsegue'),
          callback: Uri.parse('tribesxyzsample://mycallback'),
        ),
        android: AndroidConfiguration(
          domain: Uri.parse('https://www.myappxyz.com'),
        ),
      ),
    );
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _requestAccount() async {
    String addy;
    try {
      final results = await CoinbaseWalletSDK.shared.initiateHandshake([
        const RequestAccounts(),
      ]);
      addy = results[0].account?.address ?? "<no address>";
    } catch (e) {
      addy = 'Failed to get address. => $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _addy = addy;
    });
  }

  Future<void> _personalSign() async {
    String message = "Hello, world!";
    String signed;
    try {
      final request = Request(
        actions: [PersonalSign(address: _addy, message: message)],
      );
      final results = await CoinbaseWalletSDK.shared.makeRequest(request);

      signed = results[0].value ?? "<no signature>";
    } catch (e) {
      debugPrint('error --> $e');
      signed = "Failed to sign message.";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _signed = signed;
    });
  }

  Future<void> _resetSession() async {
    try {
      await CoinbaseWalletSDK.shared.resetSession();
      setState(() {
        _sessionCleared = "SEssion Cleared!";
      });
    } catch (e) {
      setState(() {
        _sessionCleared = "Failed to reset session";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Coinbase Flutter SDK'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FutureBuilder<bool>(
                future: CoinbaseWalletSDK.shared.isAppInstalled(),
                builder: ((context, snapshot) {
                  return Text(
                    'Is installed? ${snapshot.data}',
                  );
                }),
              ),
              TextButton(
                onPressed: () => _requestAccount(),
                child: const Text("Request Account"),
              ),
              Text('address is\n\n $_addy'),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () => _personalSign(),
                child: const Text("personalSign"),
              ),
              Text('signed message is\n\n $_signed'),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () => _resetSession(),
                child: const Text("Reset Session"),
              ),
              Text('is reset\n\n $_sessionCleared'),
            ],
          ),
        ),
      ),
    );
  }
}
