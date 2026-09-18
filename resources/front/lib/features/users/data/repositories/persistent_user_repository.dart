import '../../../../core/storage/local_storage_service.dart';
import '../../domain/models/user_model.dart';
import '../../domain/models/user_status.dart';
import 'user_repository.dart';

/// Persistent User Repository that saves and loads participants from durable storage.
class PersistentUserRepository implements UserRepository {
  static const String _storageKey = 'alfager_users';
  final LocalStorageService storageService;
  final List<UserModel> _cachedUsers = [];
  bool _isLoaded = false;

  PersistentUserRepository({required this.storageService});

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    final jsonList = await storageService.readJsonList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _cachedUsers.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            _cachedUsers.add(UserModel.fromJson(item));
          } catch (_) {}
        }
      }
    } else {
      // Pre-seed with default realistic participants if fresh install
      _cachedUsers.addAll(_defaultSeedUsers);
      await _persist();
    }
    _isLoaded = true;
  }

  Future<void> _persist() async {
    final list = _cachedUsers.map((u) => u.toJson()).toList();
    await storageService.writeJsonList(_storageKey, list);
  }

  @override
  Future<List<UserModel>> getUsers() async {
    await _ensureLoaded();
    return List.unmodifiable(_cachedUsers);
  }

  @override
  Future<UserModel?> getUserById(String id) async {
    await _ensureLoaded();
    try {
      return _cachedUsers.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _ensureLoaded();
    final index = _cachedUsers.indexWhere((u) => u.id == user.id);
    if (index >= 0) {
      _cachedUsers[index] = user;
    } else {
      _cachedUsers.add(user);
    }
    await _persist();
  }

  @override
  Future<void> deleteUser(String id) async {
    await _ensureLoaded();
    _cachedUsers.removeWhere((u) => u.id == id);
    await _persist();
  }

  @override
  Future<void> updateUserStatus(String id, UserStatus newStatus) async {
    await _ensureLoaded();
    final index = _cachedUsers.indexWhere((u) => u.id == id);
    if (index >= 0) {
      _cachedUsers[index] = _cachedUsers[index].copyWith(status: newStatus);
      await _persist();
    }
  }

  @override
  Future<void> resetAllUsersForSession() async {
    await _ensureLoaded();
    for (int i = 0; i < _cachedUsers.length; i++) {
      if (_cachedUsers[i].status != UserStatus.optedOut) {
        _cachedUsers[i] = _cachedUsers[i].copyWith(
          status: UserStatus.pending,
          retryCount: 0,
          snoozeCount: 0,
          totalCallsMadeToday: 0,
        );
      }
    }
    await _persist();
  }

  static final List<UserModel> _defaultSeedUsers = [
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
}
