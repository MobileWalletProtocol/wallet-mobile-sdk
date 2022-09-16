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
    required String? toAddress,
    required BigInt weiValue,
    required String data,
    required int? nonce,
    required BigInt? gasPriceInWei,
    required BigInt? maxFeePerGas,
    required BigInt? maxPriorityFeePerGas,
    required BigInt? gasLimit,
    required String chainId,
  }) : super(
          method: 'eth_signTransaction',
          paramsJson: jsonEncode({
            'fromAddress': fromAddress,
            'toAddress': toAddress,
            'weiValue': weiValue.toString(),
            'data': data,
            'nonce': nonce,
            'gasPriceInWei': gasPriceInWei?.toString(),
            'maxFeePerGas': maxFeePerGas?.toString(),
            'maxPriorityFeePerGas': maxPriorityFeePerGas?.toString(),
            'gasLimit': gasLimit?.toString(),
            'chainId': chainId,
          }),
        );
}

class SendTransaction extends Action {
  SendTransaction({
    required String fromAddress,
    required String? toAddress,
    required BigInt weiValue,
    required String data,
    required int? nonce,
    required BigInt? gasPriceInWei,
    required BigInt? maxFeePerGas,
    required BigInt? maxPriorityFeePerGas,
    required BigInt? gasLimit,
    required String chainId,
  }) : super(
          method: 'eth_signTransaction',
          paramsJson: jsonEncode({
            'fromAddress': fromAddress,
            'toAddress': toAddress,
            'weiValue': weiValue.toString(),
            'data': data,
            'nonce': nonce,
            'gasPriceInWei': gasPriceInWei?.toString(),
            'maxFeePerGas': maxFeePerGas?.toString(),
            'maxPriorityFeePerGas': maxPriorityFeePerGas?.toString(),
            'gasLimit': gasLimit?.toString(),
            'chainId': chainId,
          }),
        );
}

class SwitchEthereumChain extends Action {
  SwitchEthereumChain({
    required int chainId,
  }) : super(
          method: 'wallet_switchEthereumChain',
          paramsJson: jsonEncode({
            'chainId': chainId,
          }),
        );
}
