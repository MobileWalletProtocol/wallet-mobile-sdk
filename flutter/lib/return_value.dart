class ReturnValue {
  final String? value;
  final ReturnValueError? error;

  const ReturnValue({
    this.value,
    this.error,
  });

  factory ReturnValue.fromJson(Map<String, dynamic> json) {
    final error = json['error'];
    return ReturnValue(
      value: json['result'] as String?,
      error: error == null
          ? null
          : ReturnValueError.fromJson(Map<String, dynamic>.from(error)),
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
