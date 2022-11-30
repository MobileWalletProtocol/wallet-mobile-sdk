class Wallet {
  final String name;
  final String? iconUrl;
  final String? url;
  final String? mwpScheme;
  final String? appStoreUrl;
  final String? packageName;

  const Wallet({
    required this.name,
    required this.iconUrl,
    required this.url,
    required this.mwpScheme,
    required this.appStoreUrl,
    required this.packageName,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'iconUrl': iconUrl,
      'url': url,
      'mwpScheme': mwpScheme,
      'appStoreUrl': appStoreUrl,
      'packageName': packageName,
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
        name: json['name'] as String,
        iconUrl: json['iconUrl'] as String?,
        url: json['url'] as String?,
        mwpScheme: json['mwpScheme'] as String?,
        appStoreUrl: json['appStoreUrl'] as String?,
        packageName: json['packageName'] as String?);
  }
}
