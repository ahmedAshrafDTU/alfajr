import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/theme/app_theme.dart';
import 'package:alfager/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:alfager/features/users/data/repositories/user_repository.dart';
import 'package:alfager/features/wake_up/domain/services/mock_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/wake_up_engine.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('DashboardScreen renders next fajr countdown, KPI cards and buttons', (WidgetTester tester) async {
    final userRepo = InMemoryUserRepository();
    final callService = MockCallService();
    final engine = WakeUpEngine(callService: callService);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: DashboardScreen(
          engine: engine,
          userRepository: userRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify key UI elements render
    expect(find.text('نظام الفجر للإيقاظ'), findsOneWidget);
    expect(find.text('موعد الفجر القادم'), findsOneWidget);
    expect(find.text('إحصائيات المتابعة اليومية'), findsOneWidget);
    expect(find.text('بدء جلسة الإيقاظ'), findsOneWidget);
    expect(find.text('إيقاف طارئ'), findsOneWidget);

    engine.dispose();
  });
}
