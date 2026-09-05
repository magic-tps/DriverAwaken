class MlPrediction {
  const MlPrediction({
    required this.predictedClass,
    required this.confidence,
    required this.awakeProbability,
    required this.fatigueProbability,
    required this.drowsyProbability,
  });

  final int predictedClass;
  final double confidence;
  final double awakeProbability;
  final double fatigueProbability;
  final double drowsyProbability;

  String get label {
    switch (predictedClass) {
      case 0:
        return 'despierto';
      case 1:
        return 'cansancio';
      case 2:
        return 'somnoliento';
      default:
        return 'desconocido';
    }
  }
}
