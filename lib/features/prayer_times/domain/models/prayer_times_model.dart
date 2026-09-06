/// Model containing calculated prayer times for a specific day and location.
class PrayerTimesModel {
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String locationName;
  final bool isManual;

  const PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.locationName = 'مكة المكرمة',
    this.isManual = false,
  });

  /// Calculates duration remaining until next Fajr.
  Duration get timeUntilFajr {
    final now = DateTime.now();
    if (fajr.isAfter(now)) {
      return fajr.difference(now);
    } else {
      // If today's Fajr has passed, calculate for tomorrow's Fajr
      final tomorrowFajr = fajr.add(const Duration(days: 1));
      return tomorrowFajr.difference(now);
    }
  }

  PrayerTimesModel copyWith({
    DateTime? date,
    DateTime? fajr,
    DateTime? sunrise,
    DateTime? dhuhr,
    DateTime? asr,
    DateTime? maghrib,
    DateTime? isha,
    String? locationName,
    bool? isManual,
  }) {
    return PrayerTimesModel(
      date: date ?? this.date,
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      locationName: locationName ?? this.locationName,
      isManual: isManual ?? this.isManual,
    );
  }
}
