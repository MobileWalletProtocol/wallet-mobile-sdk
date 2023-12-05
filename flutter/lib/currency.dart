class Currency {
  final String name;
  final String symbol;
  final int decimals;

  Currency({
    required this.name,
    required this.symbol,
    required this.decimals,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'symbol': symbol, 'decimals': decimals};
  }
}
