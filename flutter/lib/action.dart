import 'dart:convert';

class Action {
  final String method;
  final String paramsJson;
  final bool optional;

  const Action({
    required this.method,
    required this.paramsJson,
    this.optional = false,
  });

  factory Action.create({
    required String method,
    required Map<String, dynamic> params,
    bool optional = false,
  }) {
    return Action(
      method: method,
      paramsJson: jsonEncode(params),
      optional: optional,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'method': method,
      'paramsJson': paramsJson,
      'optional': optional,
    };
  }
}
