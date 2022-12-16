import 'dart:async';

import 'package:coinbase_wallet_sdk/mwp_client.dart';
import 'package:coinbase_wallet_sdk/configuration.dart';
import 'package:coinbase_wallet_sdk/eth_web3_rpc.dart';
import 'package:coinbase_wallet_sdk/request.dart';
import 'package:coinbase_wallet_sdk/wallet.dart';
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
  MWPClient? _client;

  @override
  void initState() {
    MWPClient.configure(
      Configuration(
        ios: IOSConfiguration(
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
      final results = await _client!.initiateHandshake([
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
      final results = await _client!.makeRequest(request);

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
      await _client!.resetSession();
      setState(() {
        _sessionCleared = "Session Cleared!";
      });
    } catch (e) {
      setState(() {
        _sessionCleared = "Failed to reset session";
      });
    }
  }

  Future<List<Wallet>> getWallets() async {
    List<Wallet> wallets = await MWPClient.getWallets();
    return wallets;
  }

  Future<void> _back() async {
    setState(() {
      _sessionCleared = "";
      _addy = "";
      _signed = "";
      _client = null;
    });
  }

  Future<void> _handleTap(Wallet? wallet) async {
    setState(() {
      if (wallet != null) _client = MWPClient(wallet: wallet);
    });
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
              if (_client == null) ...[
                Expanded(child: projectWidget())
              ] else ...[
                Text('Connected With ${_client!.wallet.name}'),
                const SizedBox(height: 50),
                Text(
                  'Is installed? ${_client!.wallet.isInstalled}',
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
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () => _back(),
                  child: const Text("Back"),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget projectWidget() {
    return FutureBuilder<List<Wallet>>(
      builder: (context, projectSnap) {
        if (projectSnap.connectionState == ConnectionState.none &&
            projectSnap.hasData == false) {
          print('project snapshot data is: ${projectSnap.data}');
          return Container();
        }
        return ListView.builder(
          itemCount: projectSnap.data?.length,
          itemBuilder: (context, index) {
            Wallet? wallet = projectSnap.data?.elementAt(index);
            return Column(
              children: <Widget>[
                ListTile(
                    contentPadding:
                        const EdgeInsets.only(top: 20, left: 20, right: 20),
                    leading: SizedBox(
                        height: 40.0,
                        width: 40.0,
                        child: wallet?.iconUrl != null
                            ? Image.network(
                                wallet!.iconUrl!,
                                fit: BoxFit.fitWidth,
                              )
                            : const Icon(
                                Icons.adjust_rounded,
                                color: Colors.black,
                                size: 40,
                              )),
                    title: Text(wallet?.name ?? ""),
                    onTap: () {
                      _handleTap(wallet);
                    })
                // Widget to display the list of project
              ],
            );
          },
        );
      },
      future: getWallets(),
    );
  }
}
