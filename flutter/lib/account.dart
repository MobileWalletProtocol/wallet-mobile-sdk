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
}
