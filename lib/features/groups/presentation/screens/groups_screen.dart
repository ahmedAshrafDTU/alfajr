import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/models/group_model.dart';
import 'add_edit_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  final GroupRepository groupRepository;

  const GroupsScreen({super.key, required this.groupRepository});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<GroupModel> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final list = await widget.groupRepository.getGroups();
    if (mounted) {
      setState(() {
        _groups = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navGroups),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            tooltip: 'إنشاء مجموعة جديدة',
            onPressed: () async {
              final created = await Navigator.of(context).push<GroupModel>(
                MaterialPageRoute(
                  builder: (_) => AddEditGroupScreen(groupRepository: widget.groupRepository),
                ),
              );
              if (created != null) {
                _loadGroups();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                final group = _groups[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(group.colorValue),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  group.name,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Switch(
                              value: group.isEnabled,
                              onChanged: (val) async {
                                final updated = group.copyWith(isEnabled: val);
                                await widget.groupRepository.saveGroup(updated);
                                _loadGroups();
                              },
                            ),
                          ],
                        ),
                        if (group.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            group.description,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBadge(
                              '${group.userIds.length} أعضاء',
                              Icons.people_outline_rounded,
                              AppColors.primaryLight,
                            ),
                            _buildBadge(
                              'إعادة بعد ${group.config.retryDelayMinutes} د',
                              Icons.replay_rounded,
                              AppColors.amber,
                            ),
                            _buildBadge(
                              'متابعة بعد ${group.config.prayerFollowUpDelayMinutes} د',
                              Icons.access_time_rounded,
                              AppColors.gold,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<GroupModel>(
            MaterialPageRoute(
              builder: (_) => AddEditGroupScreen(groupRepository: widget.groupRepository),
            ),
          );
          if (created != null) {
            _loadGroups();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.group_add_rounded),
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
