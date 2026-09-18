import '../../domain/models/group_model.dart';
import '../../domain/models/wake_up_config.dart';

abstract class GroupRepository {
  Future<List<GroupModel>> getGroups();
  Future<GroupModel?> getGroupById(String id);
  Future<void> saveGroup(GroupModel group);
  Future<void> deleteGroup(String id);
}

class InMemoryGroupRepository implements GroupRepository {
  final List<GroupModel> _groups = [
    GroupModel(
      id: 'grp_family',
      name: 'العائلة الكريمة',
      description: 'مجموعة أفراد الأسرة المقربين',
      colorValue: 0xFF0D5C3A,
      isEnabled: true,
      config: const WakeUpConfig(
        retryDelayMinutes: 3,
        maxRetries: 2,
        prayerFollowUpDelayMinutes: 10,
      ),
      userIds: ['usr_1', 'usr_2'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    GroupModel(
      id: 'grp_mosque',
      name: 'رواد مسجد الحي',
      description: 'جماعة صلاة الفجر في المسجد',
      colorValue: 0xFFD4AF37,
      isEnabled: true,
      config: const WakeUpConfig(
        retryDelayMinutes: 4,
        maxRetries: 3,
        prayerFollowUpDelayMinutes: 8,
      ),
      userIds: ['usr_3', 'usr_4'],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    GroupModel(
      id: 'grp_students',
      name: 'طلاب السكن الجامعي',
      description: 'مجموعة طلاب الجامعة للمذاكرة والفجر',
      colorValue: 0xFF3B82F6,
      isEnabled: true,
      config: const WakeUpConfig(
        retryDelayMinutes: 2,
        maxRetries: 3,
        prayerFollowUpDelayMinutes: 12,
      ),
      userIds: ['usr_5', 'usr_6'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Future<List<GroupModel>> getGroups() async {
    return List.from(_groups);
  }

  @override
  Future<GroupModel?> getGroupById(String id) async {
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveGroup(GroupModel group) async {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      _groups[index] = group;
    } else {
      _groups.add(group);
    }
  }

  @override
  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
  }
}
