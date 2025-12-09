// WEEK7: Feature Vector untuk AI InsightMind
class FeatureVector {
  final double screeningScore; // Skor dari kuisioner
  final double activityMean; // Rata-rata magnitude accelerometer
  final double activityVar; // Variansi accelerometer (indikator stres)
  final double ppgMean; // Rata-rata sinyal PPG-like
  final double ppgVar; // Variansi PPG-like

  FeatureVector({
    required this.screeningScore,
    required this.activityMean,
    required this.activityVar,
    required this.ppgMean,
    required this.ppgVar,
  });
}
