// lib/config.dart

class Config {
  static final Config _instance = Config._internal();

  factory Config() {
    return _instance;
  }

  Config._internal();

  final String apiDomain = "https://onnstage.in/api";

  String get baseDomain => apiDomain.replaceFirst('/api', '');
}
