import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/ml_prediction.dart';
import 'model_input_preprocessor.dart';

class DrowsinessModelService {
  static const String _modelAsset = 'assets/models/drowsiness_mlp.tflite';
  static const String _metadataAsset =
      'assets/models/preprocessing_metadata.json';
  static const String _manifestAsset = 'assets/models/model_manifest.json';
  static const String _flutterExtractorVersion = 'mlkit-flutter-v1';

  Interpreter? _interpreter;
  ModelInputPreprocessor? _preprocessor;
  bool _available = false;
  bool _debugLogging = false;
  String? _lastError;
  List<double> _lastInput = <double>[];
  List<double> _lastOutput = <double>[];

  bool get isAvailable => _available;
  String? get lastError => _lastError;
  List<double> get lastInput => List<double>.unmodifiable(_lastInput);
  List<double> get lastOutput => List<double>.unmodifiable(_lastOutput);
  List<String> get featureColumns =>
      _preprocessor?.featureColumns ?? const <String>[];

  void setDebugLogging(bool enabled) {
    _debugLogging = enabled;
  }

  Future<void> initialize() async {
    if (_interpreter != null) {
      return;
    }

    try {
      final metadataText = await rootBundle.loadString(_metadataAsset);
      final metadata = jsonDecode(metadataText) as Map<String, dynamic>;
      final manifestText = await rootBundle.loadString(_manifestAsset);
      final manifest = jsonDecode(manifestText) as Map<String, dynamic>;
      final modelData = await rootBundle.load(_modelAsset);
      final modelBytes = modelData.buffer.asUint8List(
        modelData.offsetInBytes,
        modelData.lengthInBytes,
      );
      final actualHash = sha256.convert(modelBytes).toString();
      final expectedHash = manifest['sha256']?.toString().toLowerCase();
      if (expectedHash == null || actualHash != expectedHash) {
        throw const FormatException('Hash SHA-256 del modelo incompatible.');
      }
      if (manifest['parity_verified'] != true ||
          manifest['extractor_version'] != _flutterExtractorVersion) {
        throw const FormatException(
          'Modelo experimental sin paridad verificada con el extractor Flutter.',
        );
      }

      final featureColumns = (metadata['feature_columns'] as List<dynamic>)
          .map((value) => value.toString())
          .toList(growable: false);
      final featureOrderHash = sha256
          .convert(utf8.encode(jsonEncode(featureColumns)))
          .toString();
      final classOrder = (manifest['class_order'] as List<dynamic>?)
          ?.map((value) => value.toString())
          .toList(growable: false);
      if (manifest['feature_order_sha256'] != featureOrderHash ||
          !listEquals(classOrder, const <String>[
            'despierto',
            'cansancio',
            'somnoliento',
          ])) {
        throw const FormatException('Orden de features o clases incompatible.');
      }
      _preprocessor = ModelInputPreprocessor(
        featureColumns: featureColumns,
        imputerMedians: _doubleList(metadata['imputer_medians']),
        scalerMeans: _doubleList(metadata['scaler_means']),
        scalerStds: _doubleList(metadata['scaler_stds']),
      );

      final featureCount = _preprocessor!.featureCount;
      final manifestInputShape = (manifest['input_shape'] as List<dynamic>?)
          ?.map((value) => (value as num).toInt())
          .toList(growable: false);
      final manifestOutputShape = (manifest['output_shape'] as List<dynamic>?)
          ?.map((value) => (value as num).toInt())
          .toList(growable: false);
      if (manifestInputShape == null ||
          manifestInputShape.length != 2 ||
          manifestInputShape.first != 1 ||
          manifestInputShape.last != featureCount ||
          manifestOutputShape == null ||
          manifestOutputShape.length != 2 ||
          manifestOutputShape.first != 1 ||
          manifestOutputShape.last != 3) {
        throw const FormatException('Shapes del manifiesto incompatibles.');
      }

      _interpreter = await Interpreter.fromAsset(_modelAsset);
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      if (inputShape.length != 2 ||
          inputShape.first != 1 ||
          inputShape.last != featureCount) {
        throw FormatException(
          'Shape de entrada incompatible: $inputShape; esperado [1, $featureCount].',
        );
      }
      if (outputShape.length != 2 ||
          outputShape.first != 1 ||
          outputShape.last != 3) {
        throw FormatException(
          'Shape de salida incompatible: $outputShape; esperado [1, 3].',
        );
      }
      _available = true;
    } catch (error) {
      _available = false;
      _lastError = error.toString();
    }
  }

  MlPrediction? predict(Map<String, double> features) {
    final interpreter = _interpreter;
    final preprocessor = _preprocessor;
    if (!_available || interpreter == null || preprocessor == null) {
      return null;
    }

    try {
      final input = preprocessor.prepare(features);
      _lastInput = input;
      final output = List<List<double>>.filled(
        1,
        List<double>.filled(3, 0),
        growable: false,
      );
      interpreter.run(<List<double>>[input], output);
      final probabilities = output.first;
      final probabilitySum = probabilities.fold<double>(
        0,
        (total, value) => total + value,
      );
      if (probabilities.length != 3 ||
          probabilities.any((value) => !value.isFinite || value.isNaN) ||
          probabilitySum < 0.98 ||
          probabilitySum > 1.02) {
        throw StateError('Salida TFLite invalida.');
      }
      _lastOutput = List<double>.from(probabilities);
      var bestIndex = 0;
      var bestValue = probabilities.first;
      for (var index = 1; index < probabilities.length; index += 1) {
        if (probabilities[index] > bestValue) {
          bestValue = probabilities[index];
          bestIndex = index;
        }
      }

      final prediction = MlPrediction(
        predictedClass: bestIndex,
        confidence: bestValue.clamp(0, 1),
        awakeProbability: _safeAt(probabilities, 0, 0).clamp(0, 1),
        fatigueProbability: _safeAt(probabilities, 1, 0).clamp(0, 1),
        drowsyProbability: _safeAt(probabilities, 2, 0).clamp(0, 1),
      );
      if (_debugLogging) {
        debugPrint(
          'TFLite output=${_lastOutput.map((v) => v.toStringAsFixed(3)).toList()} '
          'class=${prediction.label} conf=${prediction.confidence.toStringAsFixed(3)}',
        );
      }
      return prediction;
    } catch (error) {
      _disableForSession(error);
      return null;
    }
  }

  void close() {
    _interpreter?.close();
    _interpreter = null;
    _available = false;
  }

  void _disableForSession(Object error) {
    _lastError = error.toString();
    _available = false;
    _interpreter?.close();
    _interpreter = null;
    _lastInput = <double>[];
    _lastOutput = <double>[];
  }

  List<double> _doubleList(Object? value) {
    if (value is! List<dynamic>) {
      return <double>[];
    }
    return value
        .map((item) {
          if (item is num) {
            return item.toDouble();
          }
          return double.tryParse(item.toString()) ?? 0.0;
        })
        .toList(growable: false);
  }

  double _safeAt(List<double> values, int index, double fallback) {
    if (index < 0 || index >= values.length) {
      return fallback;
    }
    final value = values[index];
    if (!value.isFinite || value.isNaN) {
      return fallback;
    }
    return value;
  }
}
