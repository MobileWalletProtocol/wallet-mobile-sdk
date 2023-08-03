import 'dart:convert';

import 'package:coinbase_wallet_sdk/action.dart';

class RequestAccounts extends Action {
  const RequestAccounts()
      : super(
          method: 'eth_requestAccounts',
          paramsJson: '{}',
        );
}

class PersonalSign extends Action {
  PersonalSign({
    required String address,
    required String message,
    bool optional = false,
  }) : super(
          method: 'personal_sign',
          paramsJson: jsonEncode({
            'address': address,
            'message': message,
          }),
          optional: optional,
        );
}

class SignTypedDataV3 extends Action {
  final String address;
  final String typedDataJson;

  SignTypedDataV3({
    required this.address,
    required this.typedDataJson,
    bool optional = false,
  }) : super(
          method: 'eth_signTypedData_v3',
          paramsJson: jsonEncode({
            'address': address,
            'typedDataJson': typedDataJson,
          }),
          optional: optional,
        );
}

class SignTypedDataV4 extends Action {
  final String address;
  final String typedDataJson;

  SignTypedDataV4({
    required this.address,
    required this.typedDataJson,
    bool optional = false,
  }) : super(
          method: 'eth_signTypedData_v4',
          paramsJson: jsonEncode({
            'address': address,
            'typedDataJson': typedDataJson,
          }),
          optional: optional,
        );
}

class SignTransaction extends Action {
  SignTransaction({
    required String fromAddress,
    required String chainId,
    required BigInt weiValue,
    required String data,
    String? toAddress,
    int? nonce,
    BigInt? gasPriceInWei,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    BigInt? gasLimit,
  }) : super(
          method: 'eth_signTransaction',
          paramsJson: jsonEncode({
            'fromAddress': fromAddress,
            'data': data,
            'chainId': chainId,
            'weiValue': weiValue.toString(),
            if (toAddress != null) 'toAddress': toAddress,
            if (nonce != null) 'nonce': nonce,
            if (gasPriceInWei != null)
              'gasPriceInWei': gasPriceInWei.toString(),
            if (maxFeePerGas != null) 'maxFeePerGas': maxFeePerGas.toString(),
            if (maxPriorityFeePerGas != null)
              'maxPriorityFeePerGas': maxPriorityFeePerGas.toString(),
            if (gasLimit != null) 'gasLimit': gasLimit.toString(),
          }),
        );
}

class SendTransaction extends Action {
  SendTransaction({
    required String fromAddress,
    required BigInt weiValue,
    required String data,
    required String chainId,
    String? toAddress,
    int? nonce,
    BigInt? gasPriceInWei,
    BigInt? maxFeePerGas,
    BigInt? maxPriorityFeePerGas,
    BigInt? gasLimit,
  }) : super(
          method: 'eth_sendTransaction',
          paramsJson: jsonEncode({
            'fromAddress': fromAddress,
            'chainId': chainId,
            'weiValue': weiValue.toString(),
            'data': data,
            if (toAddress != null) 'toAddress': toAddress,
            if (nonce != null) 'nonce': nonce,
            if (gasPriceInWei != null)
              'gasPriceInWei': gasPriceInWei.toString(),
            if (maxFeePerGas != null) 'maxFeePerGas': maxFeePerGas.toString(),
            if (maxPriorityFeePerGas != null)
              'maxPriorityFeePerGas': maxPriorityFeePerGas.toString(),
            if (gasLimit != null) 'gasLimit': gasLimit.toString(),
          }),
        );
}

class SwitchEthereumChain extends Action {
  SwitchEthereumChain({
    required String chainId,
  }) : super(
          method: 'wallet_switchEthereumChain',
          paramsJson: jsonEncode({
            'chainId': chainId,
          }),
        );
}
