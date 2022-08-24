import 'package:coinbase_wallet_sdk_flutter/account.dart';
import 'package:coinbase_wallet_sdk_flutter/action.dart';

class Request {
  final List<Action> actions;
  final Account? account;

  const Request({
    required this.actions,
    this.account,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'actions': actions.map((action) => action.toJson()).toList(),
      'account': account?.toJson(),
    };
  }
}
