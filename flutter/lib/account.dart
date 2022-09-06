class Account {
  final String chain;
  final int networkId;
  final String address;

  const Account({
    required this.chain,
    required this.networkId,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'chain': chain,
      'networkId': networkId,
      'address': address,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      chain: json['chain'] as String,
      networkId: json['networkId'] as int,
      address: json['address'] as String,
    );
  }
}
