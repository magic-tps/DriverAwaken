import 'package:flutter/foundation.dart';

abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

abstract interface class Logger {
  void info(String message);
  void warning(String message, [Object? error, StackTrace? stackTrace]);
  void error(String message, Object error, StackTrace stackTrace);
}

abstract interface class LifecycleController {
  Future<void> movedToBackground();
  void movedToForeground();
}

class DebugLogger implements Logger {
  const DebugLogger();

  @override
  void error(String message, Object error, StackTrace stackTrace) {
    debugPrint('$message: $error\n$stackTrace');
  }

  @override
  void info(String message) => debugPrint(message);

  @override
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint(error == null ? message : '$message: $error');
  }
}
