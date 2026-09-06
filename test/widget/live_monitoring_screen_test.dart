import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/core/theme/app_theme.dart';
import 'package:alfager/features/users/data/repositories/user_repository.dart';
import 'package:alfager/features/wake_up/domain/services/mock_call_service.dart';
import 'package:alfager/features/wake_up/domain/services/wake_up_engine.dart';
import 'package:alfager/features/wake_up/presentation/screens/live_monitoring_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('LiveMonitoringScreen renders participant tabs and filter chips', (WidgetTester tester) async {
    final userRepo = InMemoryUserRepository();
    final callService = MockCallService();
    final engine = WakeUpEngine(callService: callService);
    final users = await userRepo.getUsers();
    engine.setUsers(users);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: LiveMonitoringScreen(
          engine: engine,
          userRepository: userRepo,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('المتابعة الحية'), findsOneWidget);
    expect(find.text('المشتركون والمتابعة'), findsOneWidget);
    expect(find.text('سجل الأحداث المباشر'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('صلوا ✅'), findsOneWidget);

    engine.dispose();
  });
}
