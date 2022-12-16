import 'coinbase_wallet_sdk_platform_interface.dart';

class Wallet {
  final String name;
  final String iconUrl;
  final String url;
  final String? mwpScheme;
  final String? appStoreUrl;
  final String? packageName;
  final bool? isInstalled;

  const Wallet({
    required this.name,
    required this.iconUrl,
    required this.url,
    this.mwpScheme,
    this.appStoreUrl,
    this.packageName,
    this.isInstalled,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'iconUrl': iconUrl,
      'url': url,
      'mwpScheme': mwpScheme,
      'appStoreUrl': appStoreUrl,
      'packageName': packageName
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
        name: json['name'] as String,
        iconUrl: json['iconUrl'] as String,
        url: json['url'] as String,
        mwpScheme: json['mwpScheme'] as String?,
        appStoreUrl: json['appStoreUrl'] as String?,
        packageName: json['packageName'] as String?,
        isInstalled: json['isInstalled'] as bool?
    );
  }

  static Future<List<Wallet>> getDefaultWallets() async {
    final result =
    await CoinbaseWalletSdkFlutterPlatform.instance.call('static_getWallets');

    final wallets =
    (result ?? []).map((e) => Wallet.fromJson(e)).cast<Wallet>().toList();
    return wallets;
  }
}
