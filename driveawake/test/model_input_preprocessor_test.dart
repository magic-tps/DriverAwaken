import 'dart:convert';
import 'dart:io';

import 'package:driveawake/services/model_input_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('golden compartido conserva orden, imputacion y escalado', () async {
    final metadata =
        jsonDecode(
              await File(
                'assets/models/preprocessing_metadata.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    final rawFixture =
        jsonDecode(
              await File(
                '../shared/test_vectors/raw_features.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;
    final expectedFixture =
        jsonDecode(
              await File(
                '../shared/test_vectors/expected_scaled_input.json',
              ).readAsString(),
            )
            as Map<String, dynamic>;

    List<double> doubles(Object? value) => (value as List<dynamic>)
        .map((item) => (item as num).toDouble())
        .toList(growable: false);
    final preprocessor = ModelInputPreprocessor(
      featureColumns: (metadata['feature_columns'] as List<dynamic>)
          .cast<String>(),
      imputerMedians: doubles(metadata['imputer_medians']),
      scalerMeans: doubles(metadata['scaler_means']),
      scalerStds: doubles(metadata['scaler_stds']),
    );
    final rawFeatures = (rawFixture['features'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    final expected = doubles(expectedFixture['values']);
    final tolerance = (expectedFixture['absolute_tolerance'] as num).toDouble();

    final actual = preprocessor.prepare(rawFeatures);

    expect(actual, hasLength(expected.length));
    for (var index = 0; index < actual.length; index += 1) {
      expect(
        actual[index],
        closeTo(expected[index], tolerance),
        reason: 'Feature ${preprocessor.featureColumns[index]} ($index)',
      );
    }
  });

  test('rechaza metadata con longitudes incompatibles', () {
    expect(
      () => ModelInputPreprocessor(
        featureColumns: const <String>['feature'],
        imputerMedians: const <double>[],
        scalerMeans: const <double>[0],
        scalerStds: const <double>[1],
      ),
      throwsFormatException,
    );
  });

  test('imputa NaN antes de escalar', () {
    final preprocessor = ModelInputPreprocessor(
      featureColumns: const <String>['feature'],
      imputerMedians: const <double>[5],
      scalerMeans: const <double>[1],
      scalerStds: const <double>[2],
    );

    expect(
      preprocessor.prepare(<String, double>{'feature': double.nan}),
      <double>[2],
    );
  });
}
