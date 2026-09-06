import '../../domain/models/user_model.dart';
import '../../domain/models/user_status.dart';

abstract class UserRepository {
  Future<List<UserModel>> getUsers();
  Future<UserModel?> getUserById(String id);
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser(String id);
  Future<void> updateUserStatus(String id, UserStatus newStatus);
  Future<void> resetAllUsersForSession();
}

/// In-memory repository with pre-seeded realistic sample participants.
class InMemoryUserRepository implements UserRepository {
  final List<UserModel> _users = [
    UserModel(
      id: 'usr_1',
      name: 'أحمد محمود',
      phone: '+966501112233',
      priority: 1,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 30)),
      notes: 'يفضل الاتصال مبكراً',
      groupId: 'grp_family',
    ),
    UserModel(
      id: 'usr_2',
      name: 'محمد عبدالله',
      phone: '+966502223344',
      priority: 1,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 20)),
      groupId: 'grp_family',
    ),
    UserModel(
      id: 'usr_3',
      name: 'طارق زياد',
      phone: '+966503334455',
      priority: 2,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 15)),
      groupId: 'grp_mosque',
    ),
    UserModel(
      id: 'usr_4',
      name: 'عمر خالد',
      phone: '+966504445566',
      priority: 2,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 10)),
      groupId: 'grp_mosque',
    ),
    UserModel(
      id: 'usr_5',
      name: 'خالد بن الوليد',
      phone: '+966505556677',
      priority: 3,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 5)),
      groupId: 'grp_students',
    ),
    UserModel(
      id: 'usr_6',
      name: 'سلمان الفارس',
      phone: '+966506667788',
      priority: 3,
      isOptedIn: true,
      optedInAt: DateTime.now().subtract(const Duration(days: 2)),
      groupId: 'grp_students',
    ),
  ];

  @override
  Future<List<UserModel>> getUsers() async {
    return List.from(_users);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    _users.removeWhere((u) => u.id == id);
  }

  @override
  Future<void> updateUserStatus(String id, UserStatus newStatus) async {
    final index = _users.indexWhere((u) => u.id == id);
    if (index >= 0) {
      _users[index] = _users[index].copyWith(status: newStatus);
    }
  }

  @override
  Future<void> resetAllUsersForSession() async {
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].status != UserStatus.optedOut) {
        _users[i] = _users[i].copyWith(
          status: UserStatus.pending,
          retryCount: 0,
          snoozeCount: 0,
          totalCallsMadeToday: 0,
        );
      }
    }
  }
}
