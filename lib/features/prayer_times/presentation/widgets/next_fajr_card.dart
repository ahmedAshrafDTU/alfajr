import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/arabic_date_formatter.dart';
import '../../domain/models/prayer_times_model.dart';

class NextFajrCard extends StatelessWidget {
  final PrayerTimesModel prayerTimes;
  final VoidCallback? onToggleManual;

  const NextFajrCard({
    super.key,
    required this.prayerTimes,
    this.onToggleManual,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = prayerTimes.timeUntilFajr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.fajrGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.nights_stay_rounded,
                      color: AppColors.goldLight,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'موعد الفجر القادم',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        prayerTimes.locationName,
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (onToggleManual != null)
                IconButton(
                  onPressed: onToggleManual,
                  icon: Icon(
                    prayerTimes.isManual ? Icons.edit_calendar_rounded : Icons.location_on_rounded,
                    color: Colors.white70,
                  ),
                  tooltip: prayerTimes.isManual ? 'تعديل التوقيت اليدوي' : 'حساب تلقائي بالموقع',
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ArabicDateFormatter.formatTime(prayerTimes.fajr),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    ArabicDateFormatter.formatDate(prayerTimes.date),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'متبقي على الأذان',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ArabicDateFormatter.formatRemainingTime(remaining),
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
