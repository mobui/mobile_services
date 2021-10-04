part of '../mobile_services.dart';

enum LogLevel {
  ERROR,
  WARN,
  INFO,
  DEBUG,
}

extension LogLevelX on LogLevel {
  String toText() {
    return this.toString().split('.').last;
  }
}

class Logger {
  final MobileServicesClient _client;
  final List<Log> _log = [];

  Logger({
    required MobileServicesClient client,
  }) : _client = client;

  void d(String message, {String location = '', String? source = '', bool sendImmediately = false}) {}

  void w(String message, {String location = '', String? source = '', bool sendImmediately = false}) {}

  void e(String message, {String location = '', String? source = '', bool sendImmediately = false}) {}

  void i(String message, {String location = '', String? source = '', bool sendImmediately = false}) {}

  void _add_log() {}
}

class Log {
  static const String DELIMITER = '#';

  final DateTime timestamp;
  final LogLevel level;
  final String appcid;
  final String source;
  final String location;
  final String message;

  Log({
    required this.timestamp,
    required this.level,
    required this.appcid,
    required this.source,
    required this.location,
    required this.message,
  });

  @override
  String toString() {
    return '$DELIMITER${timestamp.toIso8601String()}$DELIMITER${level.toText()}$DELIMITER$appcid' +
        '$DELIMITER$source$DELIMITER$location$DELIMITER$message';
  }
}
