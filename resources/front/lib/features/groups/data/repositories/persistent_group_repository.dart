import '../../../../core/storage/local_storage_service.dart';
import '../../domain/models/group_model.dart';
import '../../domain/models/wake_up_config.dart';
import 'group_repository.dart';

/// Persistent Group Repository using durable local storage.
class PersistentGroupRepository implements GroupRepository {
  static const String _storageKey = 'alfager_groups';
  final LocalStorageService storageService;
  final List<GroupModel> _cachedGroups = [];
  bool _isLoaded = false;

  PersistentGroupRepository({required this.storageService});

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    final jsonList = await storageService.readJsonList(_storageKey);
    if (jsonList != null && jsonList.isNotEmpty) {
      _cachedGroups.clear();
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          try {
            _cachedGroups.add(GroupModel.fromJson(item));
          } catch (_) {}
        }
      }
    } else {
      _cachedGroups.addAll(_defaultSeedGroups);
      await _persist();
    }
    _isLoaded = true;
  }

  Future<void> _persist() async {
    final list = _cachedGroups.map((g) => g.toJson()).toList();
    await storageService.writeJsonList(_storageKey, list);
  }

  @override
  Future<List<GroupModel>> getGroups() async {
    await _ensureLoaded();
    return List.unmodifiable(_cachedGroups);
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    await _ensureLoaded();
    try {
      return _cachedGroups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGroup(GroupModel group) async {
    await _ensureLoaded();
    final index = _cachedGroups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      _cachedGroups[index] = group;
    } else {
      _cachedGroups.add(group);
    }
    await _persist();
  }

  @override
  Future<void> deleteGroup(String id) async {
    await _ensureLoaded();
    _cachedGroups.removeWhere((g) => g.id == id);
    await _persist();
  }

  static final List<GroupModel> _defaultSeedGroups = [
    GroupModel(
      id: 'grp_family',
      name: 'العائلة الكريمة',
      description: 'أفراد الأسرة والأقارب',
      colorValue: 0xFF0D5C3A,
      config: const WakeUpConfig(
        retryDelayMinutes: 3,
        maxRetries: 3,
        prayerFollowUpDelayMinutes: 10,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    GroupModel(
      id: 'grp_mosque',
      name: 'رواد المسجد',
      description: 'جيران ورواد مسجد الحي',
      colorValue: 0xFFC59B27,
      config: const WakeUpConfig(
        retryDelayMinutes: 2,
        maxRetries: 2,
        prayerFollowUpDelayMinutes: 15,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
    GroupModel(
      id: 'grp_students',
      name: 'طلاب السكن الجامعي',
      description: 'مجموعة الشباب وطلاب الجامعة',
      colorValue: 0xFF1B65A4,
      config: const WakeUpConfig(
        retryDelayMinutes: 2,
        maxRetries: 4,
        prayerFollowUpDelayMinutes: 8,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];
}
