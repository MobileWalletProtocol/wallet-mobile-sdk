class Configuration {
  final IOSConfiguration? ios;
  final AndroidConfiguration? android;

  Configuration({
    required this.ios,
    required this.android,
  });
}

class IOSConfiguration {
  final Uri host;
  final Uri callback;

  const IOSConfiguration({
    required this.host,
    required this.callback,
  });

  Map<String, dynamic> toJson() {
    return {
      'host': host.toString(),
      'callback': callback.toString(),
    };
  }
}

class AndroidConfiguration {
  final Uri domain;

  const AndroidConfiguration({
    required this.domain,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'domain': domain.toString(),
    };
  }
}
