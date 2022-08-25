class ReturnValue {
  final String? value;
  final ReturnValueError? error;

  const ReturnValue({
    this.value,
    this.error,
  });

  factory ReturnValue.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final error = json['error'];
    return ReturnValue(
      value: result == null ? null : result['value'] as String,
      error: error == null
          ? null
          : ReturnValueError.fromJson(error as Map<String, dynamic>),
    );
  }
}

class ReturnValueError {
  final int code;
  final String message;

  const ReturnValueError(this.code, this.message);

  factory ReturnValueError.fromJson(Map<String, dynamic> json) {
    return ReturnValueError(
      json['code'] as int,
      json['message'] as String,
    );
  }
}
