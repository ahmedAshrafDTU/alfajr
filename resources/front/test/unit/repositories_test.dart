import 'package:flutter_test/flutter_test.dart';
import 'package:alfager/features/users/data/repositories/user_repository.dart';
import 'package:alfager/features/users/domain/models/user_model.dart';
import 'package:alfager/features/users/domain/models/user_status.dart';
import 'package:alfager/features/groups/data/repositories/group_repository.dart';
import 'package:alfager/features/groups/domain/models/group_model.dart';
import 'package:alfager/features/history_analytics/data/repositories/history_repository.dart';

void main() {
  group('Repository Unit Tests', () {
    test('UserRepository saves, fetches, updates, and deletes users', () async {
      final repo = InMemoryUserRepository();
      final users = await repo.getUsers();
      expect(users.isNotEmpty, isTrue);

      const newUser = UserModel(
        id: 'test_123',
        name: 'مستخدم تجريبي',
        phone: '+966599999999',
        isOptedIn: true,
      );

      await repo.saveUser(newUser);
      final fetched = await repo.getUserById('test_123');
      expect(fetched?.name, equals('مستخدم تجريبي'));

      await repo.updateUserStatus('test_123', UserStatus.awake);
      final updated = await repo.getUserById('test_123');
      expect(updated?.status, equals(UserStatus.awake));

      await repo.deleteUser('test_123');
      final deleted = await repo.getUserById('test_123');
      expect(deleted, isNull);
    });

    test('GroupRepository manages groups', () async {
      final repo = InMemoryGroupRepository();
      final groups = await repo.getGroups();
      expect(groups.isNotEmpty, isTrue);

      final newGroup = GroupModel(
        id: 'grp_test',
        name: 'مجموعة تجريبية',
        createdAt: DateTime.now(),
      );

      await repo.saveGroup(newGroup);
      final fetched = await repo.getGroupById('grp_test');
      expect(fetched?.name, equals('مجموعة تجريبية'));
    });

    test('HistoryRepository returns accurate analytics computations', () async {
      final repo = InMemoryHistoryRepository();
      final analytics = await repo.getAnalytics();

      expect(analytics.overallWakeUpRate, greaterThan(0));
      expect(analytics.overallPrayerConfirmationRate, greaterThan(0));
      expect(analytics.weeklyTrends.isNotEmpty, isTrue);
    });
  });
}
