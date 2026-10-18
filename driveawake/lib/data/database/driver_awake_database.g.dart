// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_awake_database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _drivingDurationMsMeta = const VerificationMeta(
    'drivingDurationMs',
  );
  @override
  late final GeneratedColumn<int> drivingDurationMs = GeneratedColumn<int>(
    'driving_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warningAlertsMeta = const VerificationMeta(
    'warningAlerts',
  );
  @override
  late final GeneratedColumn<int> warningAlerts = GeneratedColumn<int>(
    'warning_alerts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dangerAlertsMeta = const VerificationMeta(
    'dangerAlerts',
  );
  @override
  late final GeneratedColumn<int> dangerAlerts = GeneratedColumn<int>(
    'danger_alerts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _yawnCountMeta = const VerificationMeta(
    'yawnCount',
  );
  @override
  late final GeneratedColumn<int> yawnCount = GeneratedColumn<int>(
    'yawn_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noFaceEventsMeta = const VerificationMeta(
    'noFaceEvents',
  );
  @override
  late final GeneratedColumn<int> noFaceEvents = GeneratedColumn<int>(
    'no_face_events',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _normalSamplesMeta = const VerificationMeta(
    'normalSamples',
  );
  @override
  late final GeneratedColumn<int> normalSamples = GeneratedColumn<int>(
    'normal_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _warningSamplesMeta = const VerificationMeta(
    'warningSamples',
  );
  @override
  late final GeneratedColumn<int> warningSamples = GeneratedColumn<int>(
    'warning_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dangerSamplesMeta = const VerificationMeta(
    'dangerSamples',
  );
  @override
  late final GeneratedColumn<int> dangerSamples = GeneratedColumn<int>(
    'danger_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _riskSumMeta = const VerificationMeta(
    'riskSum',
  );
  @override
  late final GeneratedColumn<double> riskSum = GeneratedColumn<double>(
    'risk_sum',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxRiskMeta = const VerificationMeta(
    'maxRisk',
  );
  @override
  late final GeneratedColumn<double> maxRisk = GeneratedColumn<double>(
    'max_risk',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _closedEyeDurationMsMeta =
      const VerificationMeta('closedEyeDurationMs');
  @override
  late final GeneratedColumn<int> closedEyeDurationMs = GeneratedColumn<int>(
    'closed_eye_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startBatteryLevelMeta = const VerificationMeta(
    'startBatteryLevel',
  );
  @override
  late final GeneratedColumn<double> startBatteryLevel =
      GeneratedColumn<double>(
        'start_battery_level',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endBatteryLevelMeta = const VerificationMeta(
    'endBatteryLevel',
  );
  @override
  late final GeneratedColumn<double> endBatteryLevel = GeneratedColumn<double>(
    'end_battery_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startTemperatureCMeta = const VerificationMeta(
    'startTemperatureC',
  );
  @override
  late final GeneratedColumn<double> startTemperatureC =
      GeneratedColumn<double>(
        'start_temperature_c',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endTemperatureCMeta = const VerificationMeta(
    'endTemperatureC',
  );
  @override
  late final GeneratedColumn<double> endTemperatureC = GeneratedColumn<double>(
    'end_temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxTemperatureCMeta = const VerificationMeta(
    'maxTemperatureC',
  );
  @override
  late final GeneratedColumn<double> maxTemperatureC = GeneratedColumn<double>(
    'max_temperature_c',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isChargingMeta = const VerificationMeta(
    'isCharging',
  );
  @override
  late final GeneratedColumn<bool> isCharging = GeneratedColumn<bool>(
    'is_charging',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_charging" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    status,
    drivingDurationMs,
    warningAlerts,
    dangerAlerts,
    yawnCount,
    noFaceEvents,
    normalSamples,
    warningSamples,
    dangerSamples,
    sampleCount,
    riskSum,
    maxRisk,
    closedEyeDurationMs,
    startBatteryLevel,
    endBatteryLevel,
    startTemperatureC,
    endTemperatureC,
    maxTemperatureC,
    isCharging,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('driving_duration_ms')) {
      context.handle(
        _drivingDurationMsMeta,
        drivingDurationMs.isAcceptableOrUnknown(
          data['driving_duration_ms']!,
          _drivingDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('warning_alerts')) {
      context.handle(
        _warningAlertsMeta,
        warningAlerts.isAcceptableOrUnknown(
          data['warning_alerts']!,
          _warningAlertsMeta,
        ),
      );
    }
    if (data.containsKey('danger_alerts')) {
      context.handle(
        _dangerAlertsMeta,
        dangerAlerts.isAcceptableOrUnknown(
          data['danger_alerts']!,
          _dangerAlertsMeta,
        ),
      );
    }
    if (data.containsKey('yawn_count')) {
      context.handle(
        _yawnCountMeta,
        yawnCount.isAcceptableOrUnknown(data['yawn_count']!, _yawnCountMeta),
      );
    }
    if (data.containsKey('no_face_events')) {
      context.handle(
        _noFaceEventsMeta,
        noFaceEvents.isAcceptableOrUnknown(
          data['no_face_events']!,
          _noFaceEventsMeta,
        ),
      );
    }
    if (data.containsKey('normal_samples')) {
      context.handle(
        _normalSamplesMeta,
        normalSamples.isAcceptableOrUnknown(
          data['normal_samples']!,
          _normalSamplesMeta,
        ),
      );
    }
    if (data.containsKey('warning_samples')) {
      context.handle(
        _warningSamplesMeta,
        warningSamples.isAcceptableOrUnknown(
          data['warning_samples']!,
          _warningSamplesMeta,
        ),
      );
    }
    if (data.containsKey('danger_samples')) {
      context.handle(
        _dangerSamplesMeta,
        dangerSamples.isAcceptableOrUnknown(
          data['danger_samples']!,
          _dangerSamplesMeta,
        ),
      );
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    }
    if (data.containsKey('risk_sum')) {
      context.handle(
        _riskSumMeta,
        riskSum.isAcceptableOrUnknown(data['risk_sum']!, _riskSumMeta),
      );
    }
    if (data.containsKey('max_risk')) {
      context.handle(
        _maxRiskMeta,
        maxRisk.isAcceptableOrUnknown(data['max_risk']!, _maxRiskMeta),
      );
    }
    if (data.containsKey('closed_eye_duration_ms')) {
      context.handle(
        _closedEyeDurationMsMeta,
        closedEyeDurationMs.isAcceptableOrUnknown(
          data['closed_eye_duration_ms']!,
          _closedEyeDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('start_battery_level')) {
      context.handle(
        _startBatteryLevelMeta,
        startBatteryLevel.isAcceptableOrUnknown(
          data['start_battery_level']!,
          _startBatteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('end_battery_level')) {
      context.handle(
        _endBatteryLevelMeta,
        endBatteryLevel.isAcceptableOrUnknown(
          data['end_battery_level']!,
          _endBatteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('start_temperature_c')) {
      context.handle(
        _startTemperatureCMeta,
        startTemperatureC.isAcceptableOrUnknown(
          data['start_temperature_c']!,
          _startTemperatureCMeta,
        ),
      );
    }
    if (data.containsKey('end_temperature_c')) {
      context.handle(
        _endTemperatureCMeta,
        endTemperatureC.isAcceptableOrUnknown(
          data['end_temperature_c']!,
          _endTemperatureCMeta,
        ),
      );
    }
    if (data.containsKey('max_temperature_c')) {
      context.handle(
        _maxTemperatureCMeta,
        maxTemperatureC.isAcceptableOrUnknown(
          data['max_temperature_c']!,
          _maxTemperatureCMeta,
        ),
      );
    }
    if (data.containsKey('is_charging')) {
      context.handle(
        _isChargingMeta,
        isCharging.isAcceptableOrUnknown(data['is_charging']!, _isChargingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      drivingDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}driving_duration_ms'],
      )!,
      warningAlerts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_alerts'],
      )!,
      dangerAlerts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}danger_alerts'],
      )!,
      yawnCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}yawn_count'],
      )!,
      noFaceEvents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}no_face_events'],
      )!,
      normalSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}normal_samples'],
      )!,
      warningSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_samples'],
      )!,
      dangerSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}danger_samples'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      riskSum: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}risk_sum'],
      )!,
      maxRisk: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_risk'],
      )!,
      closedEyeDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}closed_eye_duration_ms'],
      )!,
      startBatteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_battery_level'],
      ),
      endBatteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_battery_level'],
      ),
      startTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_temperature_c'],
      ),
      endTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_temperature_c'],
      ),
      maxTemperatureC: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_temperature_c'],
      ),
      isCharging: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_charging'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final int drivingDurationMs;
  final int warningAlerts;
  final int dangerAlerts;
  final int yawnCount;
  final int noFaceEvents;
  final int normalSamples;
  final int warningSamples;
  final int dangerSamples;
  final int sampleCount;
  final double riskSum;
  final double maxRisk;
  final int closedEyeDurationMs;
  final double? startBatteryLevel;
  final double? endBatteryLevel;
  final double? startTemperatureC;
  final double? endTemperatureC;
  final double? maxTemperatureC;
  final bool isCharging;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TripRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.status,
    required this.drivingDurationMs,
    required this.warningAlerts,
    required this.dangerAlerts,
    required this.yawnCount,
    required this.noFaceEvents,
    required this.normalSamples,
    required this.warningSamples,
    required this.dangerSamples,
    required this.sampleCount,
    required this.riskSum,
    required this.maxRisk,
    required this.closedEyeDurationMs,
    this.startBatteryLevel,
    this.endBatteryLevel,
    this.startTemperatureC,
    this.endTemperatureC,
    this.maxTemperatureC,
    required this.isCharging,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    map['driving_duration_ms'] = Variable<int>(drivingDurationMs);
    map['warning_alerts'] = Variable<int>(warningAlerts);
    map['danger_alerts'] = Variable<int>(dangerAlerts);
    map['yawn_count'] = Variable<int>(yawnCount);
    map['no_face_events'] = Variable<int>(noFaceEvents);
    map['normal_samples'] = Variable<int>(normalSamples);
    map['warning_samples'] = Variable<int>(warningSamples);
    map['danger_samples'] = Variable<int>(dangerSamples);
    map['sample_count'] = Variable<int>(sampleCount);
    map['risk_sum'] = Variable<double>(riskSum);
    map['max_risk'] = Variable<double>(maxRisk);
    map['closed_eye_duration_ms'] = Variable<int>(closedEyeDurationMs);
    if (!nullToAbsent || startBatteryLevel != null) {
      map['start_battery_level'] = Variable<double>(startBatteryLevel);
    }
    if (!nullToAbsent || endBatteryLevel != null) {
      map['end_battery_level'] = Variable<double>(endBatteryLevel);
    }
    if (!nullToAbsent || startTemperatureC != null) {
      map['start_temperature_c'] = Variable<double>(startTemperatureC);
    }
    if (!nullToAbsent || endTemperatureC != null) {
      map['end_temperature_c'] = Variable<double>(endTemperatureC);
    }
    if (!nullToAbsent || maxTemperatureC != null) {
      map['max_temperature_c'] = Variable<double>(maxTemperatureC);
    }
    map['is_charging'] = Variable<bool>(isCharging);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      drivingDurationMs: Value(drivingDurationMs),
      warningAlerts: Value(warningAlerts),
      dangerAlerts: Value(dangerAlerts),
      yawnCount: Value(yawnCount),
      noFaceEvents: Value(noFaceEvents),
      normalSamples: Value(normalSamples),
      warningSamples: Value(warningSamples),
      dangerSamples: Value(dangerSamples),
      sampleCount: Value(sampleCount),
      riskSum: Value(riskSum),
      maxRisk: Value(maxRisk),
      closedEyeDurationMs: Value(closedEyeDurationMs),
      startBatteryLevel: startBatteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(startBatteryLevel),
      endBatteryLevel: endBatteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(endBatteryLevel),
      startTemperatureC: startTemperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(startTemperatureC),
      endTemperatureC: endTemperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(endTemperatureC),
      maxTemperatureC: maxTemperatureC == null && nullToAbsent
          ? const Value.absent()
          : Value(maxTemperatureC),
      isCharging: Value(isCharging),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      drivingDurationMs: serializer.fromJson<int>(json['drivingDurationMs']),
      warningAlerts: serializer.fromJson<int>(json['warningAlerts']),
      dangerAlerts: serializer.fromJson<int>(json['dangerAlerts']),
      yawnCount: serializer.fromJson<int>(json['yawnCount']),
      noFaceEvents: serializer.fromJson<int>(json['noFaceEvents']),
      normalSamples: serializer.fromJson<int>(json['normalSamples']),
      warningSamples: serializer.fromJson<int>(json['warningSamples']),
      dangerSamples: serializer.fromJson<int>(json['dangerSamples']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      riskSum: serializer.fromJson<double>(json['riskSum']),
      maxRisk: serializer.fromJson<double>(json['maxRisk']),
      closedEyeDurationMs: serializer.fromJson<int>(
        json['closedEyeDurationMs'],
      ),
      startBatteryLevel: serializer.fromJson<double?>(
        json['startBatteryLevel'],
      ),
      endBatteryLevel: serializer.fromJson<double?>(json['endBatteryLevel']),
      startTemperatureC: serializer.fromJson<double?>(
        json['startTemperatureC'],
      ),
      endTemperatureC: serializer.fromJson<double?>(json['endTemperatureC']),
      maxTemperatureC: serializer.fromJson<double?>(json['maxTemperatureC']),
      isCharging: serializer.fromJson<bool>(json['isCharging']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'drivingDurationMs': serializer.toJson<int>(drivingDurationMs),
      'warningAlerts': serializer.toJson<int>(warningAlerts),
      'dangerAlerts': serializer.toJson<int>(dangerAlerts),
      'yawnCount': serializer.toJson<int>(yawnCount),
      'noFaceEvents': serializer.toJson<int>(noFaceEvents),
      'normalSamples': serializer.toJson<int>(normalSamples),
      'warningSamples': serializer.toJson<int>(warningSamples),
      'dangerSamples': serializer.toJson<int>(dangerSamples),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'riskSum': serializer.toJson<double>(riskSum),
      'maxRisk': serializer.toJson<double>(maxRisk),
      'closedEyeDurationMs': serializer.toJson<int>(closedEyeDurationMs),
      'startBatteryLevel': serializer.toJson<double?>(startBatteryLevel),
      'endBatteryLevel': serializer.toJson<double?>(endBatteryLevel),
      'startTemperatureC': serializer.toJson<double?>(startTemperatureC),
      'endTemperatureC': serializer.toJson<double?>(endTemperatureC),
      'maxTemperatureC': serializer.toJson<double?>(maxTemperatureC),
      'isCharging': serializer.toJson<bool>(isCharging),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripRow copyWith({
    String? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    int? drivingDurationMs,
    int? warningAlerts,
    int? dangerAlerts,
    int? yawnCount,
    int? noFaceEvents,
    int? normalSamples,
    int? warningSamples,
    int? dangerSamples,
    int? sampleCount,
    double? riskSum,
    double? maxRisk,
    int? closedEyeDurationMs,
    Value<double?> startBatteryLevel = const Value.absent(),
    Value<double?> endBatteryLevel = const Value.absent(),
    Value<double?> startTemperatureC = const Value.absent(),
    Value<double?> endTemperatureC = const Value.absent(),
    Value<double?> maxTemperatureC = const Value.absent(),
    bool? isCharging,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TripRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    drivingDurationMs: drivingDurationMs ?? this.drivingDurationMs,
    warningAlerts: warningAlerts ?? this.warningAlerts,
    dangerAlerts: dangerAlerts ?? this.dangerAlerts,
    yawnCount: yawnCount ?? this.yawnCount,
    noFaceEvents: noFaceEvents ?? this.noFaceEvents,
    normalSamples: normalSamples ?? this.normalSamples,
    warningSamples: warningSamples ?? this.warningSamples,
    dangerSamples: dangerSamples ?? this.dangerSamples,
    sampleCount: sampleCount ?? this.sampleCount,
    riskSum: riskSum ?? this.riskSum,
    maxRisk: maxRisk ?? this.maxRisk,
    closedEyeDurationMs: closedEyeDurationMs ?? this.closedEyeDurationMs,
    startBatteryLevel: startBatteryLevel.present
        ? startBatteryLevel.value
        : this.startBatteryLevel,
    endBatteryLevel: endBatteryLevel.present
        ? endBatteryLevel.value
        : this.endBatteryLevel,
    startTemperatureC: startTemperatureC.present
        ? startTemperatureC.value
        : this.startTemperatureC,
    endTemperatureC: endTemperatureC.present
        ? endTemperatureC.value
        : this.endTemperatureC,
    maxTemperatureC: maxTemperatureC.present
        ? maxTemperatureC.value
        : this.maxTemperatureC,
    isCharging: isCharging ?? this.isCharging,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      drivingDurationMs: data.drivingDurationMs.present
          ? data.drivingDurationMs.value
          : this.drivingDurationMs,
      warningAlerts: data.warningAlerts.present
          ? data.warningAlerts.value
          : this.warningAlerts,
      dangerAlerts: data.dangerAlerts.present
          ? data.dangerAlerts.value
          : this.dangerAlerts,
      yawnCount: data.yawnCount.present ? data.yawnCount.value : this.yawnCount,
      noFaceEvents: data.noFaceEvents.present
          ? data.noFaceEvents.value
          : this.noFaceEvents,
      normalSamples: data.normalSamples.present
          ? data.normalSamples.value
          : this.normalSamples,
      warningSamples: data.warningSamples.present
          ? data.warningSamples.value
          : this.warningSamples,
      dangerSamples: data.dangerSamples.present
          ? data.dangerSamples.value
          : this.dangerSamples,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      riskSum: data.riskSum.present ? data.riskSum.value : this.riskSum,
      maxRisk: data.maxRisk.present ? data.maxRisk.value : this.maxRisk,
      closedEyeDurationMs: data.closedEyeDurationMs.present
          ? data.closedEyeDurationMs.value
          : this.closedEyeDurationMs,
      startBatteryLevel: data.startBatteryLevel.present
          ? data.startBatteryLevel.value
          : this.startBatteryLevel,
      endBatteryLevel: data.endBatteryLevel.present
          ? data.endBatteryLevel.value
          : this.endBatteryLevel,
      startTemperatureC: data.startTemperatureC.present
          ? data.startTemperatureC.value
          : this.startTemperatureC,
      endTemperatureC: data.endTemperatureC.present
          ? data.endTemperatureC.value
          : this.endTemperatureC,
      maxTemperatureC: data.maxTemperatureC.present
          ? data.maxTemperatureC.value
          : this.maxTemperatureC,
      isCharging: data.isCharging.present
          ? data.isCharging.value
          : this.isCharging,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('drivingDurationMs: $drivingDurationMs, ')
          ..write('warningAlerts: $warningAlerts, ')
          ..write('dangerAlerts: $dangerAlerts, ')
          ..write('yawnCount: $yawnCount, ')
          ..write('noFaceEvents: $noFaceEvents, ')
          ..write('normalSamples: $normalSamples, ')
          ..write('warningSamples: $warningSamples, ')
          ..write('dangerSamples: $dangerSamples, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('riskSum: $riskSum, ')
          ..write('maxRisk: $maxRisk, ')
          ..write('closedEyeDurationMs: $closedEyeDurationMs, ')
          ..write('startBatteryLevel: $startBatteryLevel, ')
          ..write('endBatteryLevel: $endBatteryLevel, ')
          ..write('startTemperatureC: $startTemperatureC, ')
          ..write('endTemperatureC: $endTemperatureC, ')
          ..write('maxTemperatureC: $maxTemperatureC, ')
          ..write('isCharging: $isCharging, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    startedAt,
    endedAt,
    status,
    drivingDurationMs,
    warningAlerts,
    dangerAlerts,
    yawnCount,
    noFaceEvents,
    normalSamples,
    warningSamples,
    dangerSamples,
    sampleCount,
    riskSum,
    maxRisk,
    closedEyeDurationMs,
    startBatteryLevel,
    endBatteryLevel,
    startTemperatureC,
    endTemperatureC,
    maxTemperatureC,
    isCharging,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.drivingDurationMs == this.drivingDurationMs &&
          other.warningAlerts == this.warningAlerts &&
          other.dangerAlerts == this.dangerAlerts &&
          other.yawnCount == this.yawnCount &&
          other.noFaceEvents == this.noFaceEvents &&
          other.normalSamples == this.normalSamples &&
          other.warningSamples == this.warningSamples &&
          other.dangerSamples == this.dangerSamples &&
          other.sampleCount == this.sampleCount &&
          other.riskSum == this.riskSum &&
          other.maxRisk == this.maxRisk &&
          other.closedEyeDurationMs == this.closedEyeDurationMs &&
          other.startBatteryLevel == this.startBatteryLevel &&
          other.endBatteryLevel == this.endBatteryLevel &&
          other.startTemperatureC == this.startTemperatureC &&
          other.endTemperatureC == this.endTemperatureC &&
          other.maxTemperatureC == this.maxTemperatureC &&
          other.isCharging == this.isCharging &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<int> drivingDurationMs;
  final Value<int> warningAlerts;
  final Value<int> dangerAlerts;
  final Value<int> yawnCount;
  final Value<int> noFaceEvents;
  final Value<int> normalSamples;
  final Value<int> warningSamples;
  final Value<int> dangerSamples;
  final Value<int> sampleCount;
  final Value<double> riskSum;
  final Value<double> maxRisk;
  final Value<int> closedEyeDurationMs;
  final Value<double?> startBatteryLevel;
  final Value<double?> endBatteryLevel;
  final Value<double?> startTemperatureC;
  final Value<double?> endTemperatureC;
  final Value<double?> maxTemperatureC;
  final Value<bool> isCharging;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.drivingDurationMs = const Value.absent(),
    this.warningAlerts = const Value.absent(),
    this.dangerAlerts = const Value.absent(),
    this.yawnCount = const Value.absent(),
    this.noFaceEvents = const Value.absent(),
    this.normalSamples = const Value.absent(),
    this.warningSamples = const Value.absent(),
    this.dangerSamples = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.riskSum = const Value.absent(),
    this.maxRisk = const Value.absent(),
    this.closedEyeDurationMs = const Value.absent(),
    this.startBatteryLevel = const Value.absent(),
    this.endBatteryLevel = const Value.absent(),
    this.startTemperatureC = const Value.absent(),
    this.endTemperatureC = const Value.absent(),
    this.maxTemperatureC = const Value.absent(),
    this.isCharging = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.drivingDurationMs = const Value.absent(),
    this.warningAlerts = const Value.absent(),
    this.dangerAlerts = const Value.absent(),
    this.yawnCount = const Value.absent(),
    this.noFaceEvents = const Value.absent(),
    this.normalSamples = const Value.absent(),
    this.warningSamples = const Value.absent(),
    this.dangerSamples = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.riskSum = const Value.absent(),
    this.maxRisk = const Value.absent(),
    this.closedEyeDurationMs = const Value.absent(),
    this.startBatteryLevel = const Value.absent(),
    this.endBatteryLevel = const Value.absent(),
    this.startTemperatureC = const Value.absent(),
    this.endTemperatureC = const Value.absent(),
    this.maxTemperatureC = const Value.absent(),
    this.isCharging = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripRow> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<int>? drivingDurationMs,
    Expression<int>? warningAlerts,
    Expression<int>? dangerAlerts,
    Expression<int>? yawnCount,
    Expression<int>? noFaceEvents,
    Expression<int>? normalSamples,
    Expression<int>? warningSamples,
    Expression<int>? dangerSamples,
    Expression<int>? sampleCount,
    Expression<double>? riskSum,
    Expression<double>? maxRisk,
    Expression<int>? closedEyeDurationMs,
    Expression<double>? startBatteryLevel,
    Expression<double>? endBatteryLevel,
    Expression<double>? startTemperatureC,
    Expression<double>? endTemperatureC,
    Expression<double>? maxTemperatureC,
    Expression<bool>? isCharging,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (drivingDurationMs != null) 'driving_duration_ms': drivingDurationMs,
      if (warningAlerts != null) 'warning_alerts': warningAlerts,
      if (dangerAlerts != null) 'danger_alerts': dangerAlerts,
      if (yawnCount != null) 'yawn_count': yawnCount,
      if (noFaceEvents != null) 'no_face_events': noFaceEvents,
      if (normalSamples != null) 'normal_samples': normalSamples,
      if (warningSamples != null) 'warning_samples': warningSamples,
      if (dangerSamples != null) 'danger_samples': dangerSamples,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (riskSum != null) 'risk_sum': riskSum,
      if (maxRisk != null) 'max_risk': maxRisk,
      if (closedEyeDurationMs != null)
        'closed_eye_duration_ms': closedEyeDurationMs,
      if (startBatteryLevel != null) 'start_battery_level': startBatteryLevel,
      if (endBatteryLevel != null) 'end_battery_level': endBatteryLevel,
      if (startTemperatureC != null) 'start_temperature_c': startTemperatureC,
      if (endTemperatureC != null) 'end_temperature_c': endTemperatureC,
      if (maxTemperatureC != null) 'max_temperature_c': maxTemperatureC,
      if (isCharging != null) 'is_charging': isCharging,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<int>? drivingDurationMs,
    Value<int>? warningAlerts,
    Value<int>? dangerAlerts,
    Value<int>? yawnCount,
    Value<int>? noFaceEvents,
    Value<int>? normalSamples,
    Value<int>? warningSamples,
    Value<int>? dangerSamples,
    Value<int>? sampleCount,
    Value<double>? riskSum,
    Value<double>? maxRisk,
    Value<int>? closedEyeDurationMs,
    Value<double?>? startBatteryLevel,
    Value<double?>? endBatteryLevel,
    Value<double?>? startTemperatureC,
    Value<double?>? endTemperatureC,
    Value<double?>? maxTemperatureC,
    Value<bool>? isCharging,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      drivingDurationMs: drivingDurationMs ?? this.drivingDurationMs,
      warningAlerts: warningAlerts ?? this.warningAlerts,
      dangerAlerts: dangerAlerts ?? this.dangerAlerts,
      yawnCount: yawnCount ?? this.yawnCount,
      noFaceEvents: noFaceEvents ?? this.noFaceEvents,
      normalSamples: normalSamples ?? this.normalSamples,
      warningSamples: warningSamples ?? this.warningSamples,
      dangerSamples: dangerSamples ?? this.dangerSamples,
      sampleCount: sampleCount ?? this.sampleCount,
      riskSum: riskSum ?? this.riskSum,
      maxRisk: maxRisk ?? this.maxRisk,
      closedEyeDurationMs: closedEyeDurationMs ?? this.closedEyeDurationMs,
      startBatteryLevel: startBatteryLevel ?? this.startBatteryLevel,
      endBatteryLevel: endBatteryLevel ?? this.endBatteryLevel,
      startTemperatureC: startTemperatureC ?? this.startTemperatureC,
      endTemperatureC: endTemperatureC ?? this.endTemperatureC,
      maxTemperatureC: maxTemperatureC ?? this.maxTemperatureC,
      isCharging: isCharging ?? this.isCharging,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (drivingDurationMs.present) {
      map['driving_duration_ms'] = Variable<int>(drivingDurationMs.value);
    }
    if (warningAlerts.present) {
      map['warning_alerts'] = Variable<int>(warningAlerts.value);
    }
    if (dangerAlerts.present) {
      map['danger_alerts'] = Variable<int>(dangerAlerts.value);
    }
    if (yawnCount.present) {
      map['yawn_count'] = Variable<int>(yawnCount.value);
    }
    if (noFaceEvents.present) {
      map['no_face_events'] = Variable<int>(noFaceEvents.value);
    }
    if (normalSamples.present) {
      map['normal_samples'] = Variable<int>(normalSamples.value);
    }
    if (warningSamples.present) {
      map['warning_samples'] = Variable<int>(warningSamples.value);
    }
    if (dangerSamples.present) {
      map['danger_samples'] = Variable<int>(dangerSamples.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (riskSum.present) {
      map['risk_sum'] = Variable<double>(riskSum.value);
    }
    if (maxRisk.present) {
      map['max_risk'] = Variable<double>(maxRisk.value);
    }
    if (closedEyeDurationMs.present) {
      map['closed_eye_duration_ms'] = Variable<int>(closedEyeDurationMs.value);
    }
    if (startBatteryLevel.present) {
      map['start_battery_level'] = Variable<double>(startBatteryLevel.value);
    }
    if (endBatteryLevel.present) {
      map['end_battery_level'] = Variable<double>(endBatteryLevel.value);
    }
    if (startTemperatureC.present) {
      map['start_temperature_c'] = Variable<double>(startTemperatureC.value);
    }
    if (endTemperatureC.present) {
      map['end_temperature_c'] = Variable<double>(endTemperatureC.value);
    }
    if (maxTemperatureC.present) {
      map['max_temperature_c'] = Variable<double>(maxTemperatureC.value);
    }
    if (isCharging.present) {
      map['is_charging'] = Variable<bool>(isCharging.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('drivingDurationMs: $drivingDurationMs, ')
          ..write('warningAlerts: $warningAlerts, ')
          ..write('dangerAlerts: $dangerAlerts, ')
          ..write('yawnCount: $yawnCount, ')
          ..write('noFaceEvents: $noFaceEvents, ')
          ..write('normalSamples: $normalSamples, ')
          ..write('warningSamples: $warningSamples, ')
          ..write('dangerSamples: $dangerSamples, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('riskSum: $riskSum, ')
          ..write('maxRisk: $maxRisk, ')
          ..write('closedEyeDurationMs: $closedEyeDurationMs, ')
          ..write('startBatteryLevel: $startBatteryLevel, ')
          ..write('endBatteryLevel: $endBatteryLevel, ')
          ..write('startTemperatureC: $startTemperatureC, ')
          ..write('endTemperatureC: $endTemperatureC, ')
          ..write('maxTemperatureC: $maxTemperatureC, ')
          ..write('isCharging: $isCharging, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripEventsTable extends TripEvents
    with TableInfo<$TripEventsTable, TripEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<double> durationSeconds = GeneratedColumn<double>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _riskScoreMeta = const VerificationMeta(
    'riskScore',
  );
  @override
  late final GeneratedColumn<double> riskScore = GeneratedColumn<double>(
    'risk_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _perclosMeta = const VerificationMeta(
    'perclos',
  );
  @override
  late final GeneratedColumn<double> perclos = GeneratedColumn<double>(
    'perclos',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _modelPredictionMeta = const VerificationMeta(
    'modelPrediction',
  );
  @override
  late final GeneratedColumn<String> modelPrediction = GeneratedColumn<String>(
    'model_prediction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelConfidenceMeta = const VerificationMeta(
    'modelConfidence',
  );
  @override
  late final GeneratedColumn<double> modelConfidence = GeneratedColumn<double>(
    'model_confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    occurredAt,
    level,
    eventType,
    durationSeconds,
    riskScore,
    perclos,
    modelPrediction,
    modelConfidence,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('risk_score')) {
      context.handle(
        _riskScoreMeta,
        riskScore.isAcceptableOrUnknown(data['risk_score']!, _riskScoreMeta),
      );
    }
    if (data.containsKey('perclos')) {
      context.handle(
        _perclosMeta,
        perclos.isAcceptableOrUnknown(data['perclos']!, _perclosMeta),
      );
    }
    if (data.containsKey('model_prediction')) {
      context.handle(
        _modelPredictionMeta,
        modelPrediction.isAcceptableOrUnknown(
          data['model_prediction']!,
          _modelPredictionMeta,
        ),
      );
    }
    if (data.containsKey('model_confidence')) {
      context.handle(
        _modelConfidenceMeta,
        modelConfidence.isAcceptableOrUnknown(
          data['model_confidence']!,
          _modelConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}duration_seconds'],
      )!,
      riskScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}risk_score'],
      )!,
      perclos: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}perclos'],
      )!,
      modelPrediction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_prediction'],
      ),
      modelConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}model_confidence'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TripEventsTable createAlias(String alias) {
    return $TripEventsTable(attachedDatabase, alias);
  }
}

class TripEventRow extends DataClass implements Insertable<TripEventRow> {
  final String id;
  final String? tripId;
  final DateTime occurredAt;
  final String level;
  final String eventType;
  final double durationSeconds;
  final double riskScore;
  final double perclos;
  final String? modelPrediction;
  final double? modelConfidence;
  final String notes;
  final DateTime createdAt;
  const TripEventRow({
    required this.id,
    this.tripId,
    required this.occurredAt,
    required this.level,
    required this.eventType,
    required this.durationSeconds,
    required this.riskScore,
    required this.perclos,
    this.modelPrediction,
    this.modelConfidence,
    required this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<String>(tripId);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['level'] = Variable<String>(level);
    map['event_type'] = Variable<String>(eventType);
    map['duration_seconds'] = Variable<double>(durationSeconds);
    map['risk_score'] = Variable<double>(riskScore);
    map['perclos'] = Variable<double>(perclos);
    if (!nullToAbsent || modelPrediction != null) {
      map['model_prediction'] = Variable<String>(modelPrediction);
    }
    if (!nullToAbsent || modelConfidence != null) {
      map['model_confidence'] = Variable<double>(modelConfidence);
    }
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TripEventsCompanion toCompanion(bool nullToAbsent) {
    return TripEventsCompanion(
      id: Value(id),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      occurredAt: Value(occurredAt),
      level: Value(level),
      eventType: Value(eventType),
      durationSeconds: Value(durationSeconds),
      riskScore: Value(riskScore),
      perclos: Value(perclos),
      modelPrediction: modelPrediction == null && nullToAbsent
          ? const Value.absent()
          : Value(modelPrediction),
      modelConfidence: modelConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(modelConfidence),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory TripEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripEventRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String?>(json['tripId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      level: serializer.fromJson<String>(json['level']),
      eventType: serializer.fromJson<String>(json['eventType']),
      durationSeconds: serializer.fromJson<double>(json['durationSeconds']),
      riskScore: serializer.fromJson<double>(json['riskScore']),
      perclos: serializer.fromJson<double>(json['perclos']),
      modelPrediction: serializer.fromJson<String?>(json['modelPrediction']),
      modelConfidence: serializer.fromJson<double?>(json['modelConfidence']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String?>(tripId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'level': serializer.toJson<String>(level),
      'eventType': serializer.toJson<String>(eventType),
      'durationSeconds': serializer.toJson<double>(durationSeconds),
      'riskScore': serializer.toJson<double>(riskScore),
      'perclos': serializer.toJson<double>(perclos),
      'modelPrediction': serializer.toJson<String?>(modelPrediction),
      'modelConfidence': serializer.toJson<double?>(modelConfidence),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TripEventRow copyWith({
    String? id,
    Value<String?> tripId = const Value.absent(),
    DateTime? occurredAt,
    String? level,
    String? eventType,
    double? durationSeconds,
    double? riskScore,
    double? perclos,
    Value<String?> modelPrediction = const Value.absent(),
    Value<double?> modelConfidence = const Value.absent(),
    String? notes,
    DateTime? createdAt,
  }) => TripEventRow(
    id: id ?? this.id,
    tripId: tripId.present ? tripId.value : this.tripId,
    occurredAt: occurredAt ?? this.occurredAt,
    level: level ?? this.level,
    eventType: eventType ?? this.eventType,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    riskScore: riskScore ?? this.riskScore,
    perclos: perclos ?? this.perclos,
    modelPrediction: modelPrediction.present
        ? modelPrediction.value
        : this.modelPrediction,
    modelConfidence: modelConfidence.present
        ? modelConfidence.value
        : this.modelConfidence,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  TripEventRow copyWithCompanion(TripEventsCompanion data) {
    return TripEventRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      level: data.level.present ? data.level.value : this.level,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      riskScore: data.riskScore.present ? data.riskScore.value : this.riskScore,
      perclos: data.perclos.present ? data.perclos.value : this.perclos,
      modelPrediction: data.modelPrediction.present
          ? data.modelPrediction.value
          : this.modelPrediction,
      modelConfidence: data.modelConfidence.present
          ? data.modelConfidence.value
          : this.modelConfidence,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripEventRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('level: $level, ')
          ..write('eventType: $eventType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('riskScore: $riskScore, ')
          ..write('perclos: $perclos, ')
          ..write('modelPrediction: $modelPrediction, ')
          ..write('modelConfidence: $modelConfidence, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    occurredAt,
    level,
    eventType,
    durationSeconds,
    riskScore,
    perclos,
    modelPrediction,
    modelConfidence,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripEventRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.occurredAt == this.occurredAt &&
          other.level == this.level &&
          other.eventType == this.eventType &&
          other.durationSeconds == this.durationSeconds &&
          other.riskScore == this.riskScore &&
          other.perclos == this.perclos &&
          other.modelPrediction == this.modelPrediction &&
          other.modelConfidence == this.modelConfidence &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class TripEventsCompanion extends UpdateCompanion<TripEventRow> {
  final Value<String> id;
  final Value<String?> tripId;
  final Value<DateTime> occurredAt;
  final Value<String> level;
  final Value<String> eventType;
  final Value<double> durationSeconds;
  final Value<double> riskScore;
  final Value<double> perclos;
  final Value<String?> modelPrediction;
  final Value<double?> modelConfidence;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TripEventsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.level = const Value.absent(),
    this.eventType = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.perclos = const Value.absent(),
    this.modelPrediction = const Value.absent(),
    this.modelConfidence = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripEventsCompanion.insert({
    required String id,
    this.tripId = const Value.absent(),
    required DateTime occurredAt,
    required String level,
    required String eventType,
    this.durationSeconds = const Value.absent(),
    this.riskScore = const Value.absent(),
    this.perclos = const Value.absent(),
    this.modelPrediction = const Value.absent(),
    this.modelConfidence = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       occurredAt = Value(occurredAt),
       level = Value(level),
       eventType = Value(eventType),
       createdAt = Value(createdAt);
  static Insertable<TripEventRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? occurredAt,
    Expression<String>? level,
    Expression<String>? eventType,
    Expression<double>? durationSeconds,
    Expression<double>? riskScore,
    Expression<double>? perclos,
    Expression<String>? modelPrediction,
    Expression<double>? modelConfidence,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (level != null) 'level': level,
      if (eventType != null) 'event_type': eventType,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (riskScore != null) 'risk_score': riskScore,
      if (perclos != null) 'perclos': perclos,
      if (modelPrediction != null) 'model_prediction': modelPrediction,
      if (modelConfidence != null) 'model_confidence': modelConfidence,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripEventsCompanion copyWith({
    Value<String>? id,
    Value<String?>? tripId,
    Value<DateTime>? occurredAt,
    Value<String>? level,
    Value<String>? eventType,
    Value<double>? durationSeconds,
    Value<double>? riskScore,
    Value<double>? perclos,
    Value<String?>? modelPrediction,
    Value<double?>? modelConfidence,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TripEventsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      occurredAt: occurredAt ?? this.occurredAt,
      level: level ?? this.level,
      eventType: eventType ?? this.eventType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      riskScore: riskScore ?? this.riskScore,
      perclos: perclos ?? this.perclos,
      modelPrediction: modelPrediction ?? this.modelPrediction,
      modelConfidence: modelConfidence ?? this.modelConfidence,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<double>(durationSeconds.value);
    }
    if (riskScore.present) {
      map['risk_score'] = Variable<double>(riskScore.value);
    }
    if (perclos.present) {
      map['perclos'] = Variable<double>(perclos.value);
    }
    if (modelPrediction.present) {
      map['model_prediction'] = Variable<String>(modelPrediction.value);
    }
    if (modelConfidence.present) {
      map['model_confidence'] = Variable<double>(modelConfidence.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripEventsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('level: $level, ')
          ..write('eventType: $eventType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('riskScore: $riskScore, ')
          ..write('perclos: $perclos, ')
          ..write('modelPrediction: $modelPrediction, ')
          ..write('modelConfidence: $modelConfidence, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionDraftsTable extends SessionDrafts
    with TableInfo<$SessionDraftsTable, SessionDraftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incompleteMeta = const VerificationMeta(
    'incomplete',
  );
  @override
  late final GeneratedColumn<bool> incomplete = GeneratedColumn<bool>(
    'incomplete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("incomplete" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    tripId,
    payloadJson,
    startedAt,
    updatedAt,
    incomplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionDraftRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('incomplete')) {
      context.handle(
        _incompleteMeta,
        incomplete.isAcceptableOrUnknown(data['incomplete']!, _incompleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tripId};
  @override
  SessionDraftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionDraftRow(
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      incomplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}incomplete'],
      )!,
    );
  }

  @override
  $SessionDraftsTable createAlias(String alias) {
    return $SessionDraftsTable(attachedDatabase, alias);
  }
}

class SessionDraftRow extends DataClass implements Insertable<SessionDraftRow> {
  final String tripId;
  final String payloadJson;
  final DateTime startedAt;
  final DateTime updatedAt;
  final bool incomplete;
  const SessionDraftRow({
    required this.tripId,
    required this.payloadJson,
    required this.startedAt,
    required this.updatedAt,
    required this.incomplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trip_id'] = Variable<String>(tripId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['incomplete'] = Variable<bool>(incomplete);
    return map;
  }

  SessionDraftsCompanion toCompanion(bool nullToAbsent) {
    return SessionDraftsCompanion(
      tripId: Value(tripId),
      payloadJson: Value(payloadJson),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
      incomplete: Value(incomplete),
    );
  }

  factory SessionDraftRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionDraftRow(
      tripId: serializer.fromJson<String>(json['tripId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      incomplete: serializer.fromJson<bool>(json['incomplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tripId': serializer.toJson<String>(tripId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'incomplete': serializer.toJson<bool>(incomplete),
    };
  }

  SessionDraftRow copyWith({
    String? tripId,
    String? payloadJson,
    DateTime? startedAt,
    DateTime? updatedAt,
    bool? incomplete,
  }) => SessionDraftRow(
    tripId: tripId ?? this.tripId,
    payloadJson: payloadJson ?? this.payloadJson,
    startedAt: startedAt ?? this.startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    incomplete: incomplete ?? this.incomplete,
  );
  SessionDraftRow copyWithCompanion(SessionDraftsCompanion data) {
    return SessionDraftRow(
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      incomplete: data.incomplete.present
          ? data.incomplete.value
          : this.incomplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionDraftRow(')
          ..write('tripId: $tripId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('incomplete: $incomplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tripId, payloadJson, startedAt, updatedAt, incomplete);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionDraftRow &&
          other.tripId == this.tripId &&
          other.payloadJson == this.payloadJson &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt &&
          other.incomplete == this.incomplete);
}

class SessionDraftsCompanion extends UpdateCompanion<SessionDraftRow> {
  final Value<String> tripId;
  final Value<String> payloadJson;
  final Value<DateTime> startedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> incomplete;
  final Value<int> rowid;
  const SessionDraftsCompanion({
    this.tripId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.incomplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionDraftsCompanion.insert({
    required String tripId,
    required String payloadJson,
    required DateTime startedAt,
    required DateTime updatedAt,
    this.incomplete = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tripId = Value(tripId),
       payloadJson = Value(payloadJson),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<SessionDraftRow> custom({
    Expression<String>? tripId,
    Expression<String>? payloadJson,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? incomplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tripId != null) 'trip_id': tripId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (incomplete != null) 'incomplete': incomplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionDraftsCompanion copyWith({
    Value<String>? tripId,
    Value<String>? payloadJson,
    Value<DateTime>? startedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? incomplete,
    Value<int>? rowid,
  }) {
    return SessionDraftsCompanion(
      tripId: tripId ?? this.tripId,
      payloadJson: payloadJson ?? this.payloadJson,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      incomplete: incomplete ?? this.incomplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (incomplete.present) {
      map['incomplete'] = Variable<bool>(incomplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionDraftsCompanion(')
          ..write('tripId: $tripId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('incomplete: $incomplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CalibrationsTable extends Calibrations
    with TableInfo<$CalibrationsTable, CalibrationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CalibrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'calibrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CalibrationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CalibrationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CalibrationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CalibrationsTable createAlias(String alias) {
    return $CalibrationsTable(attachedDatabase, alias);
  }
}

class CalibrationRow extends DataClass implements Insertable<CalibrationRow> {
  final String id;
  final int version;
  final String payloadJson;
  final DateTime updatedAt;
  const CalibrationRow({
    required this.id,
    required this.version,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CalibrationsCompanion toCompanion(bool nullToAbsent) {
    return CalibrationsCompanion(
      id: Value(id),
      version: Value(version),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory CalibrationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CalibrationRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CalibrationRow copyWith({
    String? id,
    int? version,
    String? payloadJson,
    DateTime? updatedAt,
  }) => CalibrationRow(
    id: id ?? this.id,
    version: version ?? this.version,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CalibrationRow copyWithCompanion(CalibrationsCompanion data) {
    return CalibrationRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CalibrationRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CalibrationRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class CalibrationsCompanion extends UpdateCompanion<CalibrationRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CalibrationsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CalibrationsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<CalibrationRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CalibrationsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CalibrationsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CalibrationsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, version, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String id;
  final int version;
  final String payloadJson;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.id,
    required this.version,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['version'] = Variable<int>(version);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      version: Value(version),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      id: serializer.fromJson<String>(json['id']),
      version: serializer.fromJson<int>(json['version']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'version': serializer.toJson<int>(version),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({
    String? id,
    int? version,
    String? payloadJson,
    DateTime? updatedAt,
  }) => AppSettingRow(
    id: id ?? this.id,
    version: version ?? this.version,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      id: data.id.present ? data.id.value : this.id,
      version: data.version.present ? data.version.value : this.version,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, version, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.id == this.id &&
          other.version == this.version &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> id;
  final Value<int> version;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.version = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String id,
    this.version = const Value.absent(),
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? id,
    Expression<int>? version,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (version != null) 'version': version,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<int>? version,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      version: version ?? this.version,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('version: $version, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelMetadataTable extends ModelMetadata
    with TableInfo<$ModelMetadataTable, ModelMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelMetadataRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ModelMetadataTable createAlias(String alias) {
    return $ModelMetadataTable(attachedDatabase, alias);
  }
}

class ModelMetadataRow extends DataClass
    implements Insertable<ModelMetadataRow> {
  final String id;
  final String payloadJson;
  final DateTime updatedAt;
  const ModelMetadataRow({
    required this.id,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ModelMetadataCompanion toCompanion(bool nullToAbsent) {
    return ModelMetadataCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory ModelMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelMetadataRow(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ModelMetadataRow copyWith({
    String? id,
    String? payloadJson,
    DateTime? updatedAt,
  }) => ModelMetadataRow(
    id: id ?? this.id,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ModelMetadataRow copyWithCompanion(ModelMetadataCompanion data) {
    return ModelMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelMetadataRow(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelMetadataRow &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class ModelMetadataCompanion extends UpdateCompanion<ModelMetadataRow> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ModelMetadataCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelMetadataCompanion.insert({
    required String id,
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<ModelMetadataRow> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelMetadataCompanion copyWith({
    Value<String>? id,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ModelMetadataCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelMetadataCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FleetOutboxTable extends FleetOutbox
    with TableInfo<$FleetOutboxTable, FleetOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FleetOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _organizationIdMeta = const VerificationMeta(
    'organizationId',
  );
  @override
  late final GeneratedColumn<String> organizationId = GeneratedColumn<String>(
    'organization_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cloudTripIdMeta = const VerificationMeta(
    'cloudTripId',
  );
  @override
  late final GeneratedColumn<String> cloudTripId = GeneratedColumn<String>(
    'cloud_trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localTripIdMeta = const VerificationMeta(
    'localTripId',
  );
  @override
  late final GeneratedColumn<String> localTripId = GeneratedColumn<String>(
    'local_trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('QUEUED'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    organizationId,
    ownerId,
    cloudTripId,
    localTripId,
    kind,
    payloadJson,
    syncStatus,
    attempts,
    nextAttemptAt,
    createdAt,
    updatedAt,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fleet_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<FleetOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('organization_id')) {
      context.handle(
        _organizationIdMeta,
        organizationId.isAcceptableOrUnknown(
          data['organization_id']!,
          _organizationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_organizationIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('cloud_trip_id')) {
      context.handle(
        _cloudTripIdMeta,
        cloudTripId.isAcceptableOrUnknown(
          data['cloud_trip_id']!,
          _cloudTripIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cloudTripIdMeta);
    }
    if (data.containsKey('local_trip_id')) {
      context.handle(
        _localTripIdMeta,
        localTripId.isAcceptableOrUnknown(
          data['local_trip_id']!,
          _localTripIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localTripIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FleetOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FleetOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      organizationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}organization_id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      cloudTripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cloud_trip_id'],
      )!,
      localTripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_trip_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $FleetOutboxTable createAlias(String alias) {
    return $FleetOutboxTable(attachedDatabase, alias);
  }
}

class FleetOutboxData extends DataClass implements Insertable<FleetOutboxData> {
  final String id;
  final String organizationId;
  final String ownerId;
  final String cloudTripId;
  final String localTripId;
  final String kind;
  final String payloadJson;
  final String syncStatus;
  final int attempts;
  final DateTime nextAttemptAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastError;
  const FleetOutboxData({
    required this.id,
    required this.organizationId,
    required this.ownerId,
    required this.cloudTripId,
    required this.localTripId,
    required this.kind,
    required this.payloadJson,
    required this.syncStatus,
    required this.attempts,
    required this.nextAttemptAt,
    required this.createdAt,
    required this.updatedAt,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['organization_id'] = Variable<String>(organizationId);
    map['owner_id'] = Variable<String>(ownerId);
    map['cloud_trip_id'] = Variable<String>(cloudTripId);
    map['local_trip_id'] = Variable<String>(localTripId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['sync_status'] = Variable<String>(syncStatus);
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  FleetOutboxCompanion toCompanion(bool nullToAbsent) {
    return FleetOutboxCompanion(
      id: Value(id),
      organizationId: Value(organizationId),
      ownerId: Value(ownerId),
      cloudTripId: Value(cloudTripId),
      localTripId: Value(localTripId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      syncStatus: Value(syncStatus),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory FleetOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FleetOutboxData(
      id: serializer.fromJson<String>(json['id']),
      organizationId: serializer.fromJson<String>(json['organizationId']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      cloudTripId: serializer.fromJson<String>(json['cloudTripId']),
      localTripId: serializer.fromJson<String>(json['localTripId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'organizationId': serializer.toJson<String>(organizationId),
      'ownerId': serializer.toJson<String>(ownerId),
      'cloudTripId': serializer.toJson<String>(cloudTripId),
      'localTripId': serializer.toJson<String>(localTripId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  FleetOutboxData copyWith({
    String? id,
    String? organizationId,
    String? ownerId,
    String? cloudTripId,
    String? localTripId,
    String? kind,
    String? payloadJson,
    String? syncStatus,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<String?> lastError = const Value.absent(),
  }) => FleetOutboxData(
    id: id ?? this.id,
    organizationId: organizationId ?? this.organizationId,
    ownerId: ownerId ?? this.ownerId,
    cloudTripId: cloudTripId ?? this.cloudTripId,
    localTripId: localTripId ?? this.localTripId,
    kind: kind ?? this.kind,
    payloadJson: payloadJson ?? this.payloadJson,
    syncStatus: syncStatus ?? this.syncStatus,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  FleetOutboxData copyWithCompanion(FleetOutboxCompanion data) {
    return FleetOutboxData(
      id: data.id.present ? data.id.value : this.id,
      organizationId: data.organizationId.present
          ? data.organizationId.value
          : this.organizationId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      cloudTripId: data.cloudTripId.present
          ? data.cloudTripId.value
          : this.cloudTripId,
      localTripId: data.localTripId.present
          ? data.localTripId.value
          : this.localTripId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FleetOutboxData(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('cloudTripId: $cloudTripId, ')
          ..write('localTripId: $localTripId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    organizationId,
    ownerId,
    cloudTripId,
    localTripId,
    kind,
    payloadJson,
    syncStatus,
    attempts,
    nextAttemptAt,
    createdAt,
    updatedAt,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FleetOutboxData &&
          other.id == this.id &&
          other.organizationId == this.organizationId &&
          other.ownerId == this.ownerId &&
          other.cloudTripId == this.cloudTripId &&
          other.localTripId == this.localTripId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.syncStatus == this.syncStatus &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastError == this.lastError);
}

class FleetOutboxCompanion extends UpdateCompanion<FleetOutboxData> {
  final Value<String> id;
  final Value<String> organizationId;
  final Value<String> ownerId;
  final Value<String> cloudTripId;
  final Value<String> localTripId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<String> syncStatus;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String?> lastError;
  final Value<int> rowid;
  const FleetOutboxCompanion({
    this.id = const Value.absent(),
    this.organizationId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.cloudTripId = const Value.absent(),
    this.localTripId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FleetOutboxCompanion.insert({
    required String id,
    required String organizationId,
    required String ownerId,
    required String cloudTripId,
    required String localTripId,
    required String kind,
    required String payloadJson,
    this.syncStatus = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime nextAttemptAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       organizationId = Value(organizationId),
       ownerId = Value(ownerId),
       cloudTripId = Value(cloudTripId),
       localTripId = Value(localTripId),
       kind = Value(kind),
       payloadJson = Value(payloadJson),
       nextAttemptAt = Value(nextAttemptAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FleetOutboxData> custom({
    Expression<String>? id,
    Expression<String>? organizationId,
    Expression<String>? ownerId,
    Expression<String>? cloudTripId,
    Expression<String>? localTripId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<String>? syncStatus,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (organizationId != null) 'organization_id': organizationId,
      if (ownerId != null) 'owner_id': ownerId,
      if (cloudTripId != null) 'cloud_trip_id': cloudTripId,
      if (localTripId != null) 'local_trip_id': localTripId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FleetOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? organizationId,
    Value<String>? ownerId,
    Value<String>? cloudTripId,
    Value<String>? localTripId,
    Value<String>? kind,
    Value<String>? payloadJson,
    Value<String>? syncStatus,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return FleetOutboxCompanion(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      ownerId: ownerId ?? this.ownerId,
      cloudTripId: cloudTripId ?? this.cloudTripId,
      localTripId: localTripId ?? this.localTripId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      syncStatus: syncStatus ?? this.syncStatus,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (organizationId.present) {
      map['organization_id'] = Variable<String>(organizationId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (cloudTripId.present) {
      map['cloud_trip_id'] = Variable<String>(cloudTripId.value);
    }
    if (localTripId.present) {
      map['local_trip_id'] = Variable<String>(localTripId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FleetOutboxCompanion(')
          ..write('id: $id, ')
          ..write('organizationId: $organizationId, ')
          ..write('ownerId: $ownerId, ')
          ..write('cloudTripId: $cloudTripId, ')
          ..write('localTripId: $localTripId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RestSessionsTable extends RestSessions
    with TableInfo<$RestSessionsTable, RestSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recommendationReasonMeta =
      const VerificationMeta('recommendationReason');
  @override
  late final GeneratedColumn<String> recommendationReason =
      GeneratedColumn<String>(
        'recommendation_reason',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _voluntarilyConfirmedMeta =
      const VerificationMeta('voluntarilyConfirmed');
  @override
  late final GeneratedColumn<bool> voluntarilyConfirmed = GeneratedColumn<bool>(
    'voluntarily_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voluntarily_confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _fleetBindingJsonMeta = const VerificationMeta(
    'fleetBindingJson',
  );
  @override
  late final GeneratedColumn<String> fleetBindingJson = GeneratedColumn<String>(
    'fleet_binding_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    startedAt,
    endedAt,
    durationMs,
    recommendationReason,
    voluntarilyConfirmed,
    fleetBindingJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rest_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('recommendation_reason')) {
      context.handle(
        _recommendationReasonMeta,
        recommendationReason.isAcceptableOrUnknown(
          data['recommendation_reason']!,
          _recommendationReasonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendationReasonMeta);
    }
    if (data.containsKey('voluntarily_confirmed')) {
      context.handle(
        _voluntarilyConfirmedMeta,
        voluntarilyConfirmed.isAcceptableOrUnknown(
          data['voluntarily_confirmed']!,
          _voluntarilyConfirmedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_voluntarilyConfirmedMeta);
    }
    if (data.containsKey('fleet_binding_json')) {
      context.handle(
        _fleetBindingJsonMeta,
        fleetBindingJson.isAcceptableOrUnknown(
          data['fleet_binding_json']!,
          _fleetBindingJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RestSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      recommendationReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendation_reason'],
      )!,
      voluntarilyConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voluntarily_confirmed'],
      )!,
      fleetBindingJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fleet_binding_json'],
      ),
    );
  }

  @override
  $RestSessionsTable createAlias(String alias) {
    return $RestSessionsTable(attachedDatabase, alias);
  }
}

class RestSessionRow extends DataClass implements Insertable<RestSessionRow> {
  final String id;
  final String tripId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMs;
  final String recommendationReason;
  final bool voluntarilyConfirmed;
  final String? fleetBindingJson;
  const RestSessionRow({
    required this.id,
    required this.tripId,
    required this.startedAt,
    this.endedAt,
    required this.durationMs,
    required this.recommendationReason,
    required this.voluntarilyConfirmed,
    this.fleetBindingJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['recommendation_reason'] = Variable<String>(recommendationReason);
    map['voluntarily_confirmed'] = Variable<bool>(voluntarilyConfirmed);
    if (!nullToAbsent || fleetBindingJson != null) {
      map['fleet_binding_json'] = Variable<String>(fleetBindingJson);
    }
    return map;
  }

  RestSessionsCompanion toCompanion(bool nullToAbsent) {
    return RestSessionsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: Value(durationMs),
      recommendationReason: Value(recommendationReason),
      voluntarilyConfirmed: Value(voluntarilyConfirmed),
      fleetBindingJson: fleetBindingJson == null && nullToAbsent
          ? const Value.absent()
          : Value(fleetBindingJson),
    );
  }

  factory RestSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestSessionRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      recommendationReason: serializer.fromJson<String>(
        json['recommendationReason'],
      ),
      voluntarilyConfirmed: serializer.fromJson<bool>(
        json['voluntarilyConfirmed'],
      ),
      fleetBindingJson: serializer.fromJson<String?>(json['fleetBindingJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMs': serializer.toJson<int>(durationMs),
      'recommendationReason': serializer.toJson<String>(recommendationReason),
      'voluntarilyConfirmed': serializer.toJson<bool>(voluntarilyConfirmed),
      'fleetBindingJson': serializer.toJson<String?>(fleetBindingJson),
    };
  }

  RestSessionRow copyWith({
    String? id,
    String? tripId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationMs,
    String? recommendationReason,
    bool? voluntarilyConfirmed,
    Value<String?> fleetBindingJson = const Value.absent(),
  }) => RestSessionRow(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs ?? this.durationMs,
    recommendationReason: recommendationReason ?? this.recommendationReason,
    voluntarilyConfirmed: voluntarilyConfirmed ?? this.voluntarilyConfirmed,
    fleetBindingJson: fleetBindingJson.present
        ? fleetBindingJson.value
        : this.fleetBindingJson,
  );
  RestSessionRow copyWithCompanion(RestSessionsCompanion data) {
    return RestSessionRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      recommendationReason: data.recommendationReason.present
          ? data.recommendationReason.value
          : this.recommendationReason,
      voluntarilyConfirmed: data.voluntarilyConfirmed.present
          ? data.voluntarilyConfirmed.value
          : this.voluntarilyConfirmed,
      fleetBindingJson: data.fleetBindingJson.present
          ? data.fleetBindingJson.value
          : this.fleetBindingJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestSessionRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('recommendationReason: $recommendationReason, ')
          ..write('voluntarilyConfirmed: $voluntarilyConfirmed, ')
          ..write('fleetBindingJson: $fleetBindingJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    startedAt,
    endedAt,
    durationMs,
    recommendationReason,
    voluntarilyConfirmed,
    fleetBindingJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestSessionRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.recommendationReason == this.recommendationReason &&
          other.voluntarilyConfirmed == this.voluntarilyConfirmed &&
          other.fleetBindingJson == this.fleetBindingJson);
}

class RestSessionsCompanion extends UpdateCompanion<RestSessionRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationMs;
  final Value<String> recommendationReason;
  final Value<bool> voluntarilyConfirmed;
  final Value<String?> fleetBindingJson;
  final Value<int> rowid;
  const RestSessionsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.recommendationReason = const Value.absent(),
    this.voluntarilyConfirmed = const Value.absent(),
    this.fleetBindingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestSessionsCompanion.insert({
    required String id,
    required String tripId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String recommendationReason,
    required bool voluntarilyConfirmed,
    this.fleetBindingJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       startedAt = Value(startedAt),
       recommendationReason = Value(recommendationReason),
       voluntarilyConfirmed = Value(voluntarilyConfirmed);
  static Insertable<RestSessionRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMs,
    Expression<String>? recommendationReason,
    Expression<bool>? voluntarilyConfirmed,
    Expression<String>? fleetBindingJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (recommendationReason != null)
        'recommendation_reason': recommendationReason,
      if (voluntarilyConfirmed != null)
        'voluntarily_confirmed': voluntarilyConfirmed,
      if (fleetBindingJson != null) 'fleet_binding_json': fleetBindingJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationMs,
    Value<String>? recommendationReason,
    Value<bool>? voluntarilyConfirmed,
    Value<String?>? fleetBindingJson,
    Value<int>? rowid,
  }) {
    return RestSessionsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      recommendationReason: recommendationReason ?? this.recommendationReason,
      voluntarilyConfirmed: voluntarilyConfirmed ?? this.voluntarilyConfirmed,
      fleetBindingJson: fleetBindingJson ?? this.fleetBindingJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (recommendationReason.present) {
      map['recommendation_reason'] = Variable<String>(
        recommendationReason.value,
      );
    }
    if (voluntarilyConfirmed.present) {
      map['voluntarily_confirmed'] = Variable<bool>(voluntarilyConfirmed.value);
    }
    if (fleetBindingJson.present) {
      map['fleet_binding_json'] = Variable<String>(fleetBindingJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestSessionsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('recommendationReason: $recommendationReason, ')
          ..write('voluntarilyConfirmed: $voluntarilyConfirmed, ')
          ..write('fleetBindingJson: $fleetBindingJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$DriverAwakeDatabase extends GeneratedDatabase {
  _$DriverAwakeDatabase(QueryExecutor e) : super(e);
  $DriverAwakeDatabaseManager get managers => $DriverAwakeDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripEventsTable tripEvents = $TripEventsTable(this);
  late final $SessionDraftsTable sessionDrafts = $SessionDraftsTable(this);
  late final $CalibrationsTable calibrations = $CalibrationsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ModelMetadataTable modelMetadata = $ModelMetadataTable(this);
  late final $FleetOutboxTable fleetOutbox = $FleetOutboxTable(this);
  late final $RestSessionsTable restSessions = $RestSessionsTable(this);
  late final Index tripEventsByTime = Index(
    'trip_events_by_time',
    'CREATE INDEX trip_events_by_time ON trip_events (occurred_at)',
  );
  late final Index tripEventsByTrip = Index(
    'trip_events_by_trip',
    'CREATE INDEX trip_events_by_trip ON trip_events (trip_id)',
  );
  late final Index tripEventsByLevel = Index(
    'trip_events_by_level',
    'CREATE INDEX trip_events_by_level ON trip_events (level)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    tripEvents,
    sessionDrafts,
    calibrations,
    appSettings,
    modelMetadata,
    fleetOutbox,
    restSessions,
    tripEventsByTime,
    tripEventsByTrip,
    tripEventsByLevel,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trip_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('session_drafts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rest_sessions', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<int> drivingDurationMs,
      Value<int> warningAlerts,
      Value<int> dangerAlerts,
      Value<int> yawnCount,
      Value<int> noFaceEvents,
      Value<int> normalSamples,
      Value<int> warningSamples,
      Value<int> dangerSamples,
      Value<int> sampleCount,
      Value<double> riskSum,
      Value<double> maxRisk,
      Value<int> closedEyeDurationMs,
      Value<double?> startBatteryLevel,
      Value<double?> endBatteryLevel,
      Value<double?> startTemperatureC,
      Value<double?> endTemperatureC,
      Value<double?> maxTemperatureC,
      Value<bool> isCharging,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<int> drivingDurationMs,
      Value<int> warningAlerts,
      Value<int> dangerAlerts,
      Value<int> yawnCount,
      Value<int> noFaceEvents,
      Value<int> normalSamples,
      Value<int> warningSamples,
      Value<int> dangerSamples,
      Value<int> sampleCount,
      Value<double> riskSum,
      Value<double> maxRisk,
      Value<int> closedEyeDurationMs,
      Value<double?> startBatteryLevel,
      Value<double?> endBatteryLevel,
      Value<double?> startTemperatureC,
      Value<double?> endTemperatureC,
      Value<double?> maxTemperatureC,
      Value<bool> isCharging,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$DriverAwakeDatabase, $TripsTable, TripRow> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripEventsTable, List<TripEventRow>>
  _tripEventsRefsTable(_$DriverAwakeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.tripEvents,
        aliasName: $_aliasNameGenerator(db.trips.id, db.tripEvents.tripId),
      );

  $$TripEventsTableProcessedTableManager get tripEventsRefs {
    final manager = $$TripEventsTableTableManager(
      $_db,
      $_db.tripEvents,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionDraftsTable, List<SessionDraftRow>>
  _sessionDraftsRefsTable(_$DriverAwakeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionDrafts,
        aliasName: $_aliasNameGenerator(db.trips.id, db.sessionDrafts.tripId),
      );

  $$SessionDraftsTableProcessedTableManager get sessionDraftsRefs {
    final manager = $$SessionDraftsTableTableManager(
      $_db,
      $_db.sessionDrafts,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionDraftsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RestSessionsTable, List<RestSessionRow>>
  _restSessionsRefsTable(_$DriverAwakeDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.restSessions,
        aliasName: $_aliasNameGenerator(db.trips.id, db.restSessions.tripId),
      );

  $$RestSessionsTableProcessedTableManager get restSessionsRefs {
    final manager = $$RestSessionsTableTableManager(
      $_db,
      $_db.restSessions,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_restSessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get drivingDurationMs => $composableBuilder(
    column: $table.drivingDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningAlerts => $composableBuilder(
    column: $table.warningAlerts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dangerAlerts => $composableBuilder(
    column: $table.dangerAlerts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yawnCount => $composableBuilder(
    column: $table.yawnCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get noFaceEvents => $composableBuilder(
    column: $table.noFaceEvents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get normalSamples => $composableBuilder(
    column: $table.normalSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningSamples => $composableBuilder(
    column: $table.warningSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dangerSamples => $composableBuilder(
    column: $table.dangerSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get riskSum => $composableBuilder(
    column: $table.riskSum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxRisk => $composableBuilder(
    column: $table.maxRisk,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get closedEyeDurationMs => $composableBuilder(
    column: $table.closedEyeDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startBatteryLevel => $composableBuilder(
    column: $table.startBatteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endBatteryLevel => $composableBuilder(
    column: $table.endBatteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startTemperatureC => $composableBuilder(
    column: $table.startTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endTemperatureC => $composableBuilder(
    column: $table.endTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxTemperatureC => $composableBuilder(
    column: $table.maxTemperatureC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripEventsRefs(
    Expression<bool> Function($$TripEventsTableFilterComposer f) f,
  ) {
    final $$TripEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripEvents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripEventsTableFilterComposer(
            $db: $db,
            $table: $db.tripEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionDraftsRefs(
    Expression<bool> Function($$SessionDraftsTableFilterComposer f) f,
  ) {
    final $$SessionDraftsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionDrafts,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionDraftsTableFilterComposer(
            $db: $db,
            $table: $db.sessionDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> restSessionsRefs(
    Expression<bool> Function($$RestSessionsTableFilterComposer f) f,
  ) {
    final $$RestSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restSessions,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestSessionsTableFilterComposer(
            $db: $db,
            $table: $db.restSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get drivingDurationMs => $composableBuilder(
    column: $table.drivingDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningAlerts => $composableBuilder(
    column: $table.warningAlerts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dangerAlerts => $composableBuilder(
    column: $table.dangerAlerts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yawnCount => $composableBuilder(
    column: $table.yawnCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get noFaceEvents => $composableBuilder(
    column: $table.noFaceEvents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get normalSamples => $composableBuilder(
    column: $table.normalSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningSamples => $composableBuilder(
    column: $table.warningSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dangerSamples => $composableBuilder(
    column: $table.dangerSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get riskSum => $composableBuilder(
    column: $table.riskSum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxRisk => $composableBuilder(
    column: $table.maxRisk,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get closedEyeDurationMs => $composableBuilder(
    column: $table.closedEyeDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startBatteryLevel => $composableBuilder(
    column: $table.startBatteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endBatteryLevel => $composableBuilder(
    column: $table.endBatteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startTemperatureC => $composableBuilder(
    column: $table.startTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endTemperatureC => $composableBuilder(
    column: $table.endTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxTemperatureC => $composableBuilder(
    column: $table.maxTemperatureC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get drivingDurationMs => $composableBuilder(
    column: $table.drivingDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warningAlerts => $composableBuilder(
    column: $table.warningAlerts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dangerAlerts => $composableBuilder(
    column: $table.dangerAlerts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yawnCount =>
      $composableBuilder(column: $table.yawnCount, builder: (column) => column);

  GeneratedColumn<int> get noFaceEvents => $composableBuilder(
    column: $table.noFaceEvents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get normalSamples => $composableBuilder(
    column: $table.normalSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warningSamples => $composableBuilder(
    column: $table.warningSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dangerSamples => $composableBuilder(
    column: $table.dangerSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get riskSum =>
      $composableBuilder(column: $table.riskSum, builder: (column) => column);

  GeneratedColumn<double> get maxRisk =>
      $composableBuilder(column: $table.maxRisk, builder: (column) => column);

  GeneratedColumn<int> get closedEyeDurationMs => $composableBuilder(
    column: $table.closedEyeDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startBatteryLevel => $composableBuilder(
    column: $table.startBatteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endBatteryLevel => $composableBuilder(
    column: $table.endBatteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startTemperatureC => $composableBuilder(
    column: $table.startTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endTemperatureC => $composableBuilder(
    column: $table.endTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxTemperatureC => $composableBuilder(
    column: $table.maxTemperatureC,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCharging => $composableBuilder(
    column: $table.isCharging,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> tripEventsRefs<T extends Object>(
    Expression<T> Function($$TripEventsTableAnnotationComposer a) f,
  ) {
    final $$TripEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripEvents,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionDraftsRefs<T extends Object>(
    Expression<T> Function($$SessionDraftsTableAnnotationComposer a) f,
  ) {
    final $$SessionDraftsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionDrafts,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionDraftsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionDrafts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> restSessionsRefs<T extends Object>(
    Expression<T> Function($$RestSessionsTableAnnotationComposer a) f,
  ) {
    final $$RestSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.restSessions,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.restSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, $$TripsTableReferences),
          TripRow,
          PrefetchHooks Function({
            bool tripEventsRefs,
            bool sessionDraftsRefs,
            bool restSessionsRefs,
          })
        > {
  $$TripsTableTableManager(_$DriverAwakeDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> drivingDurationMs = const Value.absent(),
                Value<int> warningAlerts = const Value.absent(),
                Value<int> dangerAlerts = const Value.absent(),
                Value<int> yawnCount = const Value.absent(),
                Value<int> noFaceEvents = const Value.absent(),
                Value<int> normalSamples = const Value.absent(),
                Value<int> warningSamples = const Value.absent(),
                Value<int> dangerSamples = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<double> riskSum = const Value.absent(),
                Value<double> maxRisk = const Value.absent(),
                Value<int> closedEyeDurationMs = const Value.absent(),
                Value<double?> startBatteryLevel = const Value.absent(),
                Value<double?> endBatteryLevel = const Value.absent(),
                Value<double?> startTemperatureC = const Value.absent(),
                Value<double?> endTemperatureC = const Value.absent(),
                Value<double?> maxTemperatureC = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                drivingDurationMs: drivingDurationMs,
                warningAlerts: warningAlerts,
                dangerAlerts: dangerAlerts,
                yawnCount: yawnCount,
                noFaceEvents: noFaceEvents,
                normalSamples: normalSamples,
                warningSamples: warningSamples,
                dangerSamples: dangerSamples,
                sampleCount: sampleCount,
                riskSum: riskSum,
                maxRisk: maxRisk,
                closedEyeDurationMs: closedEyeDurationMs,
                startBatteryLevel: startBatteryLevel,
                endBatteryLevel: endBatteryLevel,
                startTemperatureC: startTemperatureC,
                endTemperatureC: endTemperatureC,
                maxTemperatureC: maxTemperatureC,
                isCharging: isCharging,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> drivingDurationMs = const Value.absent(),
                Value<int> warningAlerts = const Value.absent(),
                Value<int> dangerAlerts = const Value.absent(),
                Value<int> yawnCount = const Value.absent(),
                Value<int> noFaceEvents = const Value.absent(),
                Value<int> normalSamples = const Value.absent(),
                Value<int> warningSamples = const Value.absent(),
                Value<int> dangerSamples = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<double> riskSum = const Value.absent(),
                Value<double> maxRisk = const Value.absent(),
                Value<int> closedEyeDurationMs = const Value.absent(),
                Value<double?> startBatteryLevel = const Value.absent(),
                Value<double?> endBatteryLevel = const Value.absent(),
                Value<double?> startTemperatureC = const Value.absent(),
                Value<double?> endTemperatureC = const Value.absent(),
                Value<double?> maxTemperatureC = const Value.absent(),
                Value<bool> isCharging = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                drivingDurationMs: drivingDurationMs,
                warningAlerts: warningAlerts,
                dangerAlerts: dangerAlerts,
                yawnCount: yawnCount,
                noFaceEvents: noFaceEvents,
                normalSamples: normalSamples,
                warningSamples: warningSamples,
                dangerSamples: dangerSamples,
                sampleCount: sampleCount,
                riskSum: riskSum,
                maxRisk: maxRisk,
                closedEyeDurationMs: closedEyeDurationMs,
                startBatteryLevel: startBatteryLevel,
                endBatteryLevel: endBatteryLevel,
                startTemperatureC: startTemperatureC,
                endTemperatureC: endTemperatureC,
                maxTemperatureC: maxTemperatureC,
                isCharging: isCharging,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripEventsRefs = false,
                sessionDraftsRefs = false,
                restSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tripEventsRefs) db.tripEvents,
                    if (sessionDraftsRefs) db.sessionDrafts,
                    if (restSessionsRefs) db.restSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (tripEventsRefs)
                        await $_getPrefetchedData<
                          TripRow,
                          $TripsTable,
                          TripEventRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._tripEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).tripEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionDraftsRefs)
                        await $_getPrefetchedData<
                          TripRow,
                          $TripsTable,
                          SessionDraftRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._sessionDraftsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionDraftsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (restSessionsRefs)
                        await $_getPrefetchedData<
                          TripRow,
                          $TripsTable,
                          RestSessionRow
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._restSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).restSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, $$TripsTableReferences),
      TripRow,
      PrefetchHooks Function({
        bool tripEventsRefs,
        bool sessionDraftsRefs,
        bool restSessionsRefs,
      })
    >;
typedef $$TripEventsTableCreateCompanionBuilder =
    TripEventsCompanion Function({
      required String id,
      Value<String?> tripId,
      required DateTime occurredAt,
      required String level,
      required String eventType,
      Value<double> durationSeconds,
      Value<double> riskScore,
      Value<double> perclos,
      Value<String?> modelPrediction,
      Value<double?> modelConfidence,
      Value<String> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TripEventsTableUpdateCompanionBuilder =
    TripEventsCompanion Function({
      Value<String> id,
      Value<String?> tripId,
      Value<DateTime> occurredAt,
      Value<String> level,
      Value<String> eventType,
      Value<double> durationSeconds,
      Value<double> riskScore,
      Value<double> perclos,
      Value<String?> modelPrediction,
      Value<double?> modelConfidence,
      Value<String> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TripEventsTableReferences
    extends
        BaseReferences<_$DriverAwakeDatabase, $TripEventsTable, TripEventRow> {
  $$TripEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$DriverAwakeDatabase db) => db.trips
      .createAlias($_aliasNameGenerator(db.tripEvents.tripId, db.trips.id));

  $$TripsTableProcessedTableManager? get tripId {
    final $_column = $_itemColumn<String>('trip_id');
    if ($_column == null) return null;
    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripEventsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $TripEventsTable> {
  $$TripEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get perclos => $composableBuilder(
    column: $table.perclos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelPrediction => $composableBuilder(
    column: $table.modelPrediction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get modelConfidence => $composableBuilder(
    column: $table.modelConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripEventsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $TripEventsTable> {
  $$TripEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get riskScore => $composableBuilder(
    column: $table.riskScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get perclos => $composableBuilder(
    column: $table.perclos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelPrediction => $composableBuilder(
    column: $table.modelPrediction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get modelConfidence => $composableBuilder(
    column: $table.modelConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripEventsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $TripEventsTable> {
  $$TripEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<double> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get riskScore =>
      $composableBuilder(column: $table.riskScore, builder: (column) => column);

  GeneratedColumn<double> get perclos =>
      $composableBuilder(column: $table.perclos, builder: (column) => column);

  GeneratedColumn<String> get modelPrediction => $composableBuilder(
    column: $table.modelPrediction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get modelConfidence => $composableBuilder(
    column: $table.modelConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripEventsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $TripEventsTable,
          TripEventRow,
          $$TripEventsTableFilterComposer,
          $$TripEventsTableOrderingComposer,
          $$TripEventsTableAnnotationComposer,
          $$TripEventsTableCreateCompanionBuilder,
          $$TripEventsTableUpdateCompanionBuilder,
          (TripEventRow, $$TripEventsTableReferences),
          TripEventRow,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripEventsTableTableManager(
    _$DriverAwakeDatabase db,
    $TripEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<double> durationSeconds = const Value.absent(),
                Value<double> riskScore = const Value.absent(),
                Value<double> perclos = const Value.absent(),
                Value<String?> modelPrediction = const Value.absent(),
                Value<double?> modelConfidence = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripEventsCompanion(
                id: id,
                tripId: tripId,
                occurredAt: occurredAt,
                level: level,
                eventType: eventType,
                durationSeconds: durationSeconds,
                riskScore: riskScore,
                perclos: perclos,
                modelPrediction: modelPrediction,
                modelConfidence: modelConfidence,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> tripId = const Value.absent(),
                required DateTime occurredAt,
                required String level,
                required String eventType,
                Value<double> durationSeconds = const Value.absent(),
                Value<double> riskScore = const Value.absent(),
                Value<double> perclos = const Value.absent(),
                Value<String?> modelPrediction = const Value.absent(),
                Value<double?> modelConfidence = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TripEventsCompanion.insert(
                id: id,
                tripId: tripId,
                occurredAt: occurredAt,
                level: level,
                eventType: eventType,
                durationSeconds: durationSeconds,
                riskScore: riskScore,
                perclos: perclos,
                modelPrediction: modelPrediction,
                modelConfidence: modelConfidence,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$TripEventsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$TripEventsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $TripEventsTable,
      TripEventRow,
      $$TripEventsTableFilterComposer,
      $$TripEventsTableOrderingComposer,
      $$TripEventsTableAnnotationComposer,
      $$TripEventsTableCreateCompanionBuilder,
      $$TripEventsTableUpdateCompanionBuilder,
      (TripEventRow, $$TripEventsTableReferences),
      TripEventRow,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$SessionDraftsTableCreateCompanionBuilder =
    SessionDraftsCompanion Function({
      required String tripId,
      required String payloadJson,
      required DateTime startedAt,
      required DateTime updatedAt,
      Value<bool> incomplete,
      Value<int> rowid,
    });
typedef $$SessionDraftsTableUpdateCompanionBuilder =
    SessionDraftsCompanion Function({
      Value<String> tripId,
      Value<String> payloadJson,
      Value<DateTime> startedAt,
      Value<DateTime> updatedAt,
      Value<bool> incomplete,
      Value<int> rowid,
    });

final class $$SessionDraftsTableReferences
    extends
        BaseReferences<
          _$DriverAwakeDatabase,
          $SessionDraftsTable,
          SessionDraftRow
        > {
  $$SessionDraftsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$DriverAwakeDatabase db) => db.trips
      .createAlias($_aliasNameGenerator(db.sessionDrafts.tripId, db.trips.id));

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionDraftsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get incomplete => $composableBuilder(
    column: $table.incomplete,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get incomplete => $composableBuilder(
    column: $table.incomplete,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $SessionDraftsTable> {
  $$SessionDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get incomplete => $composableBuilder(
    column: $table.incomplete,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionDraftsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $SessionDraftsTable,
          SessionDraftRow,
          $$SessionDraftsTableFilterComposer,
          $$SessionDraftsTableOrderingComposer,
          $$SessionDraftsTableAnnotationComposer,
          $$SessionDraftsTableCreateCompanionBuilder,
          $$SessionDraftsTableUpdateCompanionBuilder,
          (SessionDraftRow, $$SessionDraftsTableReferences),
          SessionDraftRow,
          PrefetchHooks Function({bool tripId})
        > {
  $$SessionDraftsTableTableManager(
    _$DriverAwakeDatabase db,
    $SessionDraftsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tripId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> incomplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionDraftsCompanion(
                tripId: tripId,
                payloadJson: payloadJson,
                startedAt: startedAt,
                updatedAt: updatedAt,
                incomplete: incomplete,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tripId,
                required String payloadJson,
                required DateTime startedAt,
                required DateTime updatedAt,
                Value<bool> incomplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionDraftsCompanion.insert(
                tripId: tripId,
                payloadJson: payloadJson,
                startedAt: startedAt,
                updatedAt: updatedAt,
                incomplete: incomplete,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionDraftsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$SessionDraftsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$SessionDraftsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $SessionDraftsTable,
      SessionDraftRow,
      $$SessionDraftsTableFilterComposer,
      $$SessionDraftsTableOrderingComposer,
      $$SessionDraftsTableAnnotationComposer,
      $$SessionDraftsTableCreateCompanionBuilder,
      $$SessionDraftsTableUpdateCompanionBuilder,
      (SessionDraftRow, $$SessionDraftsTableReferences),
      SessionDraftRow,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$CalibrationsTableCreateCompanionBuilder =
    CalibrationsCompanion Function({
      required String id,
      Value<int> version,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CalibrationsTableUpdateCompanionBuilder =
    CalibrationsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CalibrationsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $CalibrationsTable> {
  $$CalibrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CalibrationsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $CalibrationsTable> {
  $$CalibrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CalibrationsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $CalibrationsTable> {
  $$CalibrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CalibrationsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $CalibrationsTable,
          CalibrationRow,
          $$CalibrationsTableFilterComposer,
          $$CalibrationsTableOrderingComposer,
          $$CalibrationsTableAnnotationComposer,
          $$CalibrationsTableCreateCompanionBuilder,
          $$CalibrationsTableUpdateCompanionBuilder,
          (
            CalibrationRow,
            BaseReferences<
              _$DriverAwakeDatabase,
              $CalibrationsTable,
              CalibrationRow
            >,
          ),
          CalibrationRow,
          PrefetchHooks Function()
        > {
  $$CalibrationsTableTableManager(
    _$DriverAwakeDatabase db,
    $CalibrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CalibrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CalibrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CalibrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CalibrationsCompanion(
                id: id,
                version: version,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CalibrationsCompanion.insert(
                id: id,
                version: version,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CalibrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $CalibrationsTable,
      CalibrationRow,
      $$CalibrationsTableFilterComposer,
      $$CalibrationsTableOrderingComposer,
      $$CalibrationsTableAnnotationComposer,
      $$CalibrationsTableCreateCompanionBuilder,
      $$CalibrationsTableUpdateCompanionBuilder,
      (
        CalibrationRow,
        BaseReferences<
          _$DriverAwakeDatabase,
          $CalibrationsTable,
          CalibrationRow
        >,
      ),
      CalibrationRow,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String id,
      Value<int> version,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<int> version,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<
              _$DriverAwakeDatabase,
              $AppSettingsTable,
              AppSettingRow
            >,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(
    _$DriverAwakeDatabase db,
    $AppSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                version: version,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int> version = const Value.absent(),
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                version: version,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$DriverAwakeDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$ModelMetadataTableCreateCompanionBuilder =
    ModelMetadataCompanion Function({
      required String id,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ModelMetadataTableUpdateCompanionBuilder =
    ModelMetadataCompanion Function({
      Value<String> id,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ModelMetadataTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $ModelMetadataTable> {
  $$ModelMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelMetadataTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $ModelMetadataTable> {
  $$ModelMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelMetadataTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $ModelMetadataTable> {
  $$ModelMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ModelMetadataTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $ModelMetadataTable,
          ModelMetadataRow,
          $$ModelMetadataTableFilterComposer,
          $$ModelMetadataTableOrderingComposer,
          $$ModelMetadataTableAnnotationComposer,
          $$ModelMetadataTableCreateCompanionBuilder,
          $$ModelMetadataTableUpdateCompanionBuilder,
          (
            ModelMetadataRow,
            BaseReferences<
              _$DriverAwakeDatabase,
              $ModelMetadataTable,
              ModelMetadataRow
            >,
          ),
          ModelMetadataRow,
          PrefetchHooks Function()
        > {
  $$ModelMetadataTableTableManager(
    _$DriverAwakeDatabase db,
    $ModelMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ModelMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ModelMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelMetadataCompanion(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ModelMetadataCompanion.insert(
                id: id,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $ModelMetadataTable,
      ModelMetadataRow,
      $$ModelMetadataTableFilterComposer,
      $$ModelMetadataTableOrderingComposer,
      $$ModelMetadataTableAnnotationComposer,
      $$ModelMetadataTableCreateCompanionBuilder,
      $$ModelMetadataTableUpdateCompanionBuilder,
      (
        ModelMetadataRow,
        BaseReferences<
          _$DriverAwakeDatabase,
          $ModelMetadataTable,
          ModelMetadataRow
        >,
      ),
      ModelMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$FleetOutboxTableCreateCompanionBuilder =
    FleetOutboxCompanion Function({
      required String id,
      required String organizationId,
      required String ownerId,
      required String cloudTripId,
      required String localTripId,
      required String kind,
      required String payloadJson,
      Value<String> syncStatus,
      Value<int> attempts,
      required DateTime nextAttemptAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$FleetOutboxTableUpdateCompanionBuilder =
    FleetOutboxCompanion Function({
      Value<String> id,
      Value<String> organizationId,
      Value<String> ownerId,
      Value<String> cloudTripId,
      Value<String> localTripId,
      Value<String> kind,
      Value<String> payloadJson,
      Value<String> syncStatus,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$FleetOutboxTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $FleetOutboxTable> {
  $$FleetOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cloudTripId => $composableBuilder(
    column: $table.cloudTripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localTripId => $composableBuilder(
    column: $table.localTripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FleetOutboxTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $FleetOutboxTable> {
  $$FleetOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cloudTripId => $composableBuilder(
    column: $table.cloudTripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localTripId => $composableBuilder(
    column: $table.localTripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FleetOutboxTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $FleetOutboxTable> {
  $$FleetOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get organizationId => $composableBuilder(
    column: $table.organizationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get cloudTripId => $composableBuilder(
    column: $table.cloudTripId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localTripId => $composableBuilder(
    column: $table.localTripId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$FleetOutboxTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $FleetOutboxTable,
          FleetOutboxData,
          $$FleetOutboxTableFilterComposer,
          $$FleetOutboxTableOrderingComposer,
          $$FleetOutboxTableAnnotationComposer,
          $$FleetOutboxTableCreateCompanionBuilder,
          $$FleetOutboxTableUpdateCompanionBuilder,
          (
            FleetOutboxData,
            BaseReferences<
              _$DriverAwakeDatabase,
              $FleetOutboxTable,
              FleetOutboxData
            >,
          ),
          FleetOutboxData,
          PrefetchHooks Function()
        > {
  $$FleetOutboxTableTableManager(
    _$DriverAwakeDatabase db,
    $FleetOutboxTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FleetOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FleetOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FleetOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> organizationId = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> cloudTripId = const Value.absent(),
                Value<String> localTripId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FleetOutboxCompanion(
                id: id,
                organizationId: organizationId,
                ownerId: ownerId,
                cloudTripId: cloudTripId,
                localTripId: localTripId,
                kind: kind,
                payloadJson: payloadJson,
                syncStatus: syncStatus,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String organizationId,
                required String ownerId,
                required String cloudTripId,
                required String localTripId,
                required String kind,
                required String payloadJson,
                Value<String> syncStatus = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required DateTime nextAttemptAt,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FleetOutboxCompanion.insert(
                id: id,
                organizationId: organizationId,
                ownerId: ownerId,
                cloudTripId: cloudTripId,
                localTripId: localTripId,
                kind: kind,
                payloadJson: payloadJson,
                syncStatus: syncStatus,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FleetOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $FleetOutboxTable,
      FleetOutboxData,
      $$FleetOutboxTableFilterComposer,
      $$FleetOutboxTableOrderingComposer,
      $$FleetOutboxTableAnnotationComposer,
      $$FleetOutboxTableCreateCompanionBuilder,
      $$FleetOutboxTableUpdateCompanionBuilder,
      (
        FleetOutboxData,
        BaseReferences<
          _$DriverAwakeDatabase,
          $FleetOutboxTable,
          FleetOutboxData
        >,
      ),
      FleetOutboxData,
      PrefetchHooks Function()
    >;
typedef $$RestSessionsTableCreateCompanionBuilder =
    RestSessionsCompanion Function({
      required String id,
      required String tripId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      required String recommendationReason,
      required bool voluntarilyConfirmed,
      Value<String?> fleetBindingJson,
      Value<int> rowid,
    });
typedef $$RestSessionsTableUpdateCompanionBuilder =
    RestSessionsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMs,
      Value<String> recommendationReason,
      Value<bool> voluntarilyConfirmed,
      Value<String?> fleetBindingJson,
      Value<int> rowid,
    });

final class $$RestSessionsTableReferences
    extends
        BaseReferences<
          _$DriverAwakeDatabase,
          $RestSessionsTable,
          RestSessionRow
        > {
  $$RestSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$DriverAwakeDatabase db) => db.trips
      .createAlias($_aliasNameGenerator(db.restSessions.tripId, db.trips.id));

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RestSessionsTableFilterComposer
    extends Composer<_$DriverAwakeDatabase, $RestSessionsTable> {
  $$RestSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendationReason => $composableBuilder(
    column: $table.recommendationReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voluntarilyConfirmed => $composableBuilder(
    column: $table.voluntarilyConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fleetBindingJson => $composableBuilder(
    column: $table.fleetBindingJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestSessionsTableOrderingComposer
    extends Composer<_$DriverAwakeDatabase, $RestSessionsTable> {
  $$RestSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendationReason => $composableBuilder(
    column: $table.recommendationReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voluntarilyConfirmed => $composableBuilder(
    column: $table.voluntarilyConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fleetBindingJson => $composableBuilder(
    column: $table.fleetBindingJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestSessionsTableAnnotationComposer
    extends Composer<_$DriverAwakeDatabase, $RestSessionsTable> {
  $$RestSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendationReason => $composableBuilder(
    column: $table.recommendationReason,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voluntarilyConfirmed => $composableBuilder(
    column: $table.voluntarilyConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fleetBindingJson => $composableBuilder(
    column: $table.fleetBindingJson,
    builder: (column) => column,
  );

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestSessionsTableTableManager
    extends
        RootTableManager<
          _$DriverAwakeDatabase,
          $RestSessionsTable,
          RestSessionRow,
          $$RestSessionsTableFilterComposer,
          $$RestSessionsTableOrderingComposer,
          $$RestSessionsTableAnnotationComposer,
          $$RestSessionsTableCreateCompanionBuilder,
          $$RestSessionsTableUpdateCompanionBuilder,
          (RestSessionRow, $$RestSessionsTableReferences),
          RestSessionRow,
          PrefetchHooks Function({bool tripId})
        > {
  $$RestSessionsTableTableManager(
    _$DriverAwakeDatabase db,
    $RestSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<String> recommendationReason = const Value.absent(),
                Value<bool> voluntarilyConfirmed = const Value.absent(),
                Value<String?> fleetBindingJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestSessionsCompanion(
                id: id,
                tripId: tripId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                recommendationReason: recommendationReason,
                voluntarilyConfirmed: voluntarilyConfirmed,
                fleetBindingJson: fleetBindingJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                required String recommendationReason,
                required bool voluntarilyConfirmed,
                Value<String?> fleetBindingJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestSessionsCompanion.insert(
                id: id,
                tripId: tripId,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                recommendationReason: recommendationReason,
                voluntarilyConfirmed: voluntarilyConfirmed,
                fleetBindingJson: fleetBindingJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RestSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$RestSessionsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$RestSessionsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RestSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$DriverAwakeDatabase,
      $RestSessionsTable,
      RestSessionRow,
      $$RestSessionsTableFilterComposer,
      $$RestSessionsTableOrderingComposer,
      $$RestSessionsTableAnnotationComposer,
      $$RestSessionsTableCreateCompanionBuilder,
      $$RestSessionsTableUpdateCompanionBuilder,
      (RestSessionRow, $$RestSessionsTableReferences),
      RestSessionRow,
      PrefetchHooks Function({bool tripId})
    >;

class $DriverAwakeDatabaseManager {
  final _$DriverAwakeDatabase _db;
  $DriverAwakeDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripEventsTableTableManager get tripEvents =>
      $$TripEventsTableTableManager(_db, _db.tripEvents);
  $$SessionDraftsTableTableManager get sessionDrafts =>
      $$SessionDraftsTableTableManager(_db, _db.sessionDrafts);
  $$CalibrationsTableTableManager get calibrations =>
      $$CalibrationsTableTableManager(_db, _db.calibrations);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ModelMetadataTableTableManager get modelMetadata =>
      $$ModelMetadataTableTableManager(_db, _db.modelMetadata);
  $$FleetOutboxTableTableManager get fleetOutbox =>
      $$FleetOutboxTableTableManager(_db, _db.fleetOutbox);
  $$RestSessionsTableTableManager get restSessions =>
      $$RestSessionsTableTableManager(_db, _db.restSessions);
}
