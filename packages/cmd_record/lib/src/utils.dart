String durationToString(Duration duration) {
  String threeDigits(int n) {
    if (n >= 100) return '$n';
    if (n >= 10) return '0$n';
    return '00$n';
  }

  String twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  final twoDigitMinutes =
      twoDigits(duration.inMinutes.remainder(Duration.minutesPerHour).toInt());
  final twoDigitSeconds = twoDigits(
      duration.inSeconds.remainder(Duration.secondsPerMinute).toInt());
  final threeDigitMillis = threeDigits(duration.inMilliseconds
      .remainder(Duration.millisecondsPerSecond)
      .toInt());
  return '$twoDigitMinutes:$twoDigitSeconds.$threeDigitMillis';
}
