import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/features/prayer_times/domain/services/prayer_calculator_service.dart';

void main() {
  group('PrayerCalculatorService Tests', () {
    test('Calculates valid astronomical prayer times for Makkah', () {
      final date = DateTime(2026, 9, 3);
      final times = PrayerCalculatorService.calculate(
        date: date,
        latitude: 21.4225,
        longitude: 39.8262,
        timezoneOffset: 3.0,
        method: CalculationMethod.ummAlQura,
      );

      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.sunrise.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
      expect(times.isManual, isFalse);
    });

    test('Manual calculation override sets exact specified Fajr time', () {
      final date = DateTime(2026, 9, 3);
      final manualTime = DateTime(2026, 9, 3, 4, 30);
      final times = PrayerCalculatorService.calculate(
        date: date,
        method: CalculationMethod.manual,
        manualFajrTime: manualTime,
      );

      expect(times.fajr.hour, equals(4));
      expect(times.fajr.minute, equals(30));
      expect(times.isManual, isTrue);
    });
  });
}
