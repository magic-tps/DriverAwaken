class ModelInputPreprocessor {
  ModelInputPreprocessor({
    required List<String> featureColumns,
    required List<double> imputerMedians,
    required List<double> scalerMeans,
    required List<double> scalerStds,
  }) : featureColumns = List<String>.unmodifiable(featureColumns),
       imputerMedians = List<double>.unmodifiable(imputerMedians),
       scalerMeans = List<double>.unmodifiable(scalerMeans),
       scalerStds = List<double>.unmodifiable(
         scalerStds.map((value) => value == 0 || !value.isFinite ? 1.0 : value),
       ) {
    final count = this.featureColumns.length;
    if (count == 0 ||
        this.imputerMedians.length != count ||
        this.scalerMeans.length != count ||
        this.scalerStds.length != count) {
      throw const FormatException(
        'Metadata incompatible: longitudes de preprocesamiento invalidas.',
      );
    }
  }

  final List<String> featureColumns;
  final List<double> imputerMedians;
  final List<double> scalerMeans;
  final List<double> scalerStds;

  int get featureCount => featureColumns.length;

  List<double> prepare(Map<String, double> features) {
    return List<double>.generate(featureCount, (index) {
      final rawValue = features[featureColumns[index]];
      final imputed = rawValue != null && rawValue.isFinite
          ? rawValue
          : imputerMedians[index];
      final scaled = (imputed - scalerMeans[index]) / scalerStds[index];
      if (!scaled.isFinite || scaled.isNaN) {
        throw StateError(
          'Feature no finita despues de escalar: ${featureColumns[index]}',
        );
      }
      return scaled;
    }, growable: false);
  }
}
