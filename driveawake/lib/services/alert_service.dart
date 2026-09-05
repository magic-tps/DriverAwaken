import 'package:vibration/vibration.dart';

import '../models/drowsiness_state.dart';
import '../utils/drowsiness_thresholds.dart';
import 'device_telemetry_service.dart';
import 'settings_service.dart';

class AlertService {
  AlertService({AlertActuator? actuator})
    : _actuator = actuator ?? DeviceAlertActuator();

  final SettingsService _settingsService = SettingsService.instance;
  final AlertActuator _actuator;
  final AlertCooldownGate _warningGate = AlertCooldownGate(
    cooldown: DrowsinessThresholds.warningAlertCooldown,
  );
  final AlertCooldownGate _dangerGate = AlertCooldownGate(
    cooldown: DrowsinessThresholds.dangerAlertCooldown,
  );

  bool _alarmActive = false;
  DateTime? _acknowledgedAt;

  bool get alarmActive => _alarmActive;

  Future<void> handleState(DrowsinessState state) async {
    await _settingsService.initialize();
    final settings = _settingsService.settings;

    if (state.alertTier <= 0 || state.level == DrowsinessLevel.normal) {
      await stopAllAlerts();
      _acknowledgedAt = null;
      return;
    }

    if (!settings.soundEnabled) {
      await _actuator.stopAlarm();
    }
    if (!settings.vibrationEnabled) {
      await _actuator.cancelVibration();
    }

    if (_isRecentlyAcknowledged(state)) {
      return;
    }

    if (state.alertTier == 1) {
      _alarmActive = false;
      return;
    }

    if (state.alertTier == 2) {
      if (_warningGate.canFire(DateTime.now()) && settings.vibrationEnabled) {
        await _actuator.vibrateShort();
      }
      return;
    }

    if (!_dangerGate.canFire(DateTime.now())) {
      return;
    }

    _alarmActive = true;
    await Future.wait(<Future<void>>[
      if (settings.soundEnabled)
        _actuator.playAlarm(repeat: state.alertTier >= 4 ? 3 : 1),
      if (settings.vibrationEnabled) _actuator.vibrateStrongly(state.alertTier),
    ]);
  }

  Future<void> acknowledgeSustainedDanger() async {
    _acknowledgedAt = DateTime.now();
    await stopAllAlerts(resetCooldowns: false);
  }

  Future<void> stopAllAlerts({bool resetCooldowns = true}) async {
    _alarmActive = false;
    if (resetCooldowns) {
      _warningGate.reset();
      _dangerGate.reset();
    }
    await Future.wait(<Future<void>>[
      _actuator.stopAlarm(),
      _actuator.cancelVibration(),
    ]);
  }

  Future<void> dispose() async {
    await stopAllAlerts();
    await _actuator.dispose();
  }

  bool _isRecentlyAcknowledged(DrowsinessState state) {
    if (state.level != DrowsinessLevel.danger) {
      return false;
    }
    final acknowledgedAt = _acknowledgedAt;
    if (acknowledgedAt == null) {
      return false;
    }
    return DateTime.now().difference(acknowledgedAt) <
        const Duration(seconds: 30);
  }
}

abstract interface class AlertActuator {
  Future<void> playAlarm({required int repeat});
  Future<void> stopAlarm();
  Future<void> vibrateShort();
  Future<void> vibrateStrongly(int tier);
  Future<void> cancelVibration();
  Future<void> dispose();
}

class DeviceAlertActuator implements AlertActuator {
  DeviceAlertActuator({DeviceTelemetryService? deviceTelemetryService})
    : _deviceTelemetryService =
          deviceTelemetryService ?? DeviceTelemetryService();

  final DeviceTelemetryService _deviceTelemetryService;

  @override
  Future<void> playAlarm({required int repeat}) {
    return _deviceTelemetryService.playAlarm(repeat: repeat);
  }

  @override
  Future<void> stopAlarm() => _deviceTelemetryService.stopAlarm();

  @override
  Future<void> cancelVibration() => Vibration.cancel();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> vibrateShort() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) {
        return;
      }
      await Vibration.vibrate(duration: 220, amplitude: 180);
    } catch (_) {
      await Vibration.vibrate(duration: 180);
    }
  }

  @override
  Future<void> vibrateStrongly(int tier) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) {
        return;
      }

      final hasCustomSupport = await Vibration.hasCustomVibrationsSupport();
      if (hasCustomSupport) {
        final pattern = tier >= 4
            ? const <int>[0, 500, 100, 600, 100, 800, 160, 900]
            : const <int>[0, 350, 120, 450, 120, 650];
        final intensities = List<int>.generate(
          pattern.length,
          (index) => index.isOdd ? 255 : 0,
          growable: false,
        );
        await Vibration.vibrate(pattern: pattern, intensities: intensities);
      } else {
        await Vibration.vibrate(
          duration: tier >= 4 ? 1400 : 900,
          amplitude: 255,
        );
      }
    } catch (_) {
      await Vibration.vibrate(duration: 700);
    }
  }
}

class AlertCooldownGate {
  AlertCooldownGate({required this.cooldown});

  final Duration cooldown;
  DateTime? _lastFireAt;

  bool canFire(DateTime now) {
    final lastFireAt = _lastFireAt;
    if (lastFireAt != null && now.difference(lastFireAt) < cooldown) {
      return false;
    }
    _lastFireAt = now;
    return true;
  }

  void reset() {
    _lastFireAt = null;
  }
}
