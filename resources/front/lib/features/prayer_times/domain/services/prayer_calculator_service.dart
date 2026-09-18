import 'dart:math' as math;
import '../models/prayer_times_model.dart';

/// Calculation method standard.
enum CalculationMethod {
  ummAlQura, // 18.5 degrees Fajr (Makkah)
  egyptian, // 19.5 degrees Fajr (Egypt)
  muslimWorldLeague, // 18 degrees Fajr
  karachi, // 18 degrees Fajr
  manual,
}

/// Service that computes exact astronomical prayer times and handles manual override mode.
class PrayerCalculatorService {
  /// Computes prayer times for given date and geographic coordinates.
  static PrayerTimesModel calculate({
    required DateTime date,
    double latitude = 21.4225, // Makkah default
    double longitude = 39.8262,
    double timezoneOffset = 3.0,
    CalculationMethod method = CalculationMethod.ummAlQura,
    DateTime? manualFajrTime,
  }) {
    if (method == CalculationMethod.manual && manualFajrTime != null) {
      final baseFajr = DateTime(
        date.year,
        date.month,
        date.day,
        manualFajrTime.hour,
        manualFajrTime.minute,
      );
      return PrayerTimesModel(
        date: date,
        fajr: baseFajr,
        sunrise: baseFajr.add(const Duration(minutes: 80)),
        dhuhr: baseFajr.add(const Duration(hours: 7)),
        asr: baseFajr.add(const Duration(hours: 10, minutes: 20)),
        maghrib: baseFajr.add(const Duration(hours: 13, minutes: 40)),
        isha: baseFajr.add(const Duration(hours: 15, minutes: 10)),
        locationName: 'توقيت يدوي مخصص',
        isManual: true,
      );
    }

    // Fajr angle by method
    double fajrAngle = 18.5;
    if (method == CalculationMethod.egyptian) {
      fajrAngle = 19.5;
    } else if (method == CalculationMethod.muslimWorldLeague || method == CalculationMethod.karachi) {
      fajrAngle = 18.0;
    }

    // Julian date calculation
    final julianDay = _calculateJulianDay(date.year, date.month, date.day);
    final d = julianDay - 2451545.0;

    // Solar coordinates
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final l = (q + 1.915 * math.sin(_degToRad(g)) + 0.020 * math.sin(_degToRad(2 * g))) % 360;
    final e = 23.439 - 0.00000036 * d;

    // Declination & Equation of time
    final sinDeclination = math.sin(_degToRad(e)) * math.sin(_degToRad(l));
    final declination = _radToDeg(math.asin(sinDeclination));

    final equationOfTime = (q / 15.0) - (_radToDeg(math.atan2(math.cos(_degToRad(e)) * math.sin(_degToRad(l)), math.cos(_degToRad(l)))) / 15.0);

    // Solar noon (Dhuhr)
    final dhuhrHours = 12 + timezoneOffset - (longitude / 15.0) - (equationOfTime * 4.0 / 60.0);

    // Sun hour angles
    final latRad = _degToRad(latitude);
    final decRad = _degToRad(declination);

    // Fajr Hour Angle
    final fajrCosH = (-math.sin(_degToRad(fajrAngle)) - (math.sin(latRad) * math.sin(decRad))) / (math.cos(latRad) * math.cos(decRad));
    final fajrHourAngle = _radToDeg(math.acos(fajrCosH.clamp(-1.0, 1.0))) / 15.0;

    // Sunrise Angle
    final sunriseCosH = (-math.sin(_degToRad(0.833)) - (math.sin(latRad) * math.sin(decRad))) / (math.cos(latRad) * math.cos(decRad));
    final sunriseHourAngle = _radToDeg(math.acos(sunriseCosH.clamp(-1.0, 1.0))) / 15.0;

    // Asr (Shafi'i: shadow = 1 + shadow at noon)
    final asrAngle = _radToDeg(math.atan(1 + math.tan(_degToRad((latitude - declination).abs()))));
    final asrCosH = (math.sin(_degToRad(90 - asrAngle)) - (math.sin(latRad) * math.sin(decRad))) / (math.cos(latRad) * math.cos(decRad));
    final asrHourAngle = _radToDeg(math.acos(asrCosH.clamp(-1.0, 1.0))) / 15.0;

    // Isha Angle (18.5 or 90 mins after Maghrib for Umm Al-Qura)
    final fajrTimeDouble = dhuhrHours - fajrHourAngle;
    final sunriseTimeDouble = dhuhrHours - sunriseHourAngle;
    final asrTimeDouble = dhuhrHours + asrHourAngle;
    final maghribTimeDouble = dhuhrHours + sunriseHourAngle;
    final ishaTimeDouble = (method == CalculationMethod.ummAlQura)
        ? maghribTimeDouble + 1.5
        : dhuhrHours + (_radToDeg(math.acos(((-math.sin(_degToRad(17.5)) - (math.sin(latRad) * math.sin(decRad))) / (math.cos(latRad) * math.cos(decRad))).clamp(-1.0, 1.0))) / 15.0);

    return PrayerTimesModel(
      date: date,
      fajr: _hoursToDateTime(date, fajrTimeDouble),
      sunrise: _hoursToDateTime(date, sunriseTimeDouble),
      dhuhr: _hoursToDateTime(date, dhuhrHours),
      asr: _hoursToDateTime(date, asrTimeDouble),
      maghrib: _hoursToDateTime(date, maghribTimeDouble),
      isha: _hoursToDateTime(date, ishaTimeDouble),
      locationName: 'مكة المكرمة (حساب تلقائي)',
      isManual: false,
    );
  }

  static double _degToRad(double degree) => degree * math.pi / 180.0;
  static double _radToDeg(double radian) => radian * 180.0 / math.pi;

  static double _calculateJulianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524.5;
  }

  static DateTime _hoursToDateTime(DateTime date, double hoursDecimal) {
    final totalMinutes = (hoursDecimal * 60).round();
    final normalizedMinutes = ((totalMinutes % 1440) + 1440) % 1440;
    final hour = normalizedMinutes ~/ 60;
    final minute = normalizedMinutes % 60;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
