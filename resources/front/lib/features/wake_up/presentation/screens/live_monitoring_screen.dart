import 'package:flutter/material.dart';
import '../../../../core/audio/audio_prompts.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/models/user_model.dart';
import '../../../users/domain/models/user_status.dart';
import '../../../users/presentation/widgets/user_card.dart';
import '../../domain/models/session_log_model.dart';
import '../../domain/services/wake_up_engine.dart';
import '../widgets/live_stats_bar.dart';
import '../widgets/timeline_log_widget.dart';
import 'live_call_modal.dart';
import '../../../users/presentation/screens/user_detail_screen.dart';

class LiveMonitoringScreen extends StatefulWidget {
  final WakeUpEngine engine;
  final UserRepository userRepository;

  const LiveMonitoringScreen({
    super.key,
    required this.engine,
    required this.userRepository,
  });

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserStatus? _selectedStatusFilter;
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _users = List.from(widget.engine.users);

    widget.engine.usersStream.listen((updated) {
      if (mounted) {
        setState(() {
          _users = List.from(updated);
        });
      }
    });

    widget.engine.logsStream.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openCallSimulation(UserModel user) {
    AudioPrompt prompt;
    if (user.status == UserStatus.awake || user.status == UserStatus.needsFollowUp) {
      prompt = AudioPrompt.fromType(AudioPromptType.prayerQuestion);
    } else {
      prompt = AudioPrompt.fromType(AudioPromptType.firstWakeUp);
    }

    showDialog(
      context: context,
      builder: (_) => LiveCallModal(
        user: user,
        prompt: prompt,
        onCompleted: (spokenResponse, intent) {
          // Trigger transition or manual status update
          widget.engine.addLog(
            userId: user.id,
            userName: user.name,
            eventType: SessionEventType.callAnswered,
            message: 'تمت المحاكاة التفاعلية لـ ${user.name}: "$spokenResponse"',
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _selectedStatusFilter == null
        ? _users
        : _users.where((u) => u.status == _selectedStatusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navLiveMonitoring),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'المشتركون والمتابعة'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'سجل الأحداث المباشر'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Live Participant Status Grid / List
          Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LiveStatsBar(users: _users),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedStatusFilter == null,
                      label: const Text('الكل'),
                      onSelected: (_) => setState(() => _selectedStatusFilter = null),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _selectedStatusFilter == UserStatus.prayed,
                      label: const Text('صلوا ✅'),
                      onSelected: (_) => setState(() => _selectedStatusFilter = UserStatus.prayed),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _selectedStatusFilter == UserStatus.awake,
                      label: const Text('مستيقظون 🟡'),
                      onSelected: (_) => setState(() => _selectedStatusFilter = UserStatus.awake),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _selectedStatusFilter == UserStatus.failed,
                      label: const Text('لم يجيبوا 🔴'),
                      onSelected: (_) => setState(() => _selectedStatusFilter = UserStatus.failed),
                    ),
                    const SizedBox(width: 6),
                    FilterChip(
                      selected: _selectedStatusFilter == UserStatus.pending,
                      label: const Text('قيد الانتظار ⚪'),
                      onSelected: (_) => setState(() => _selectedStatusFilter = UserStatus.pending),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: filteredUsers.isEmpty
                    ? const Center(child: Text('لا يوجد مشتركون بهذه الحالة'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return UserCard(
                            user: user,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserDetailScreen(
                                    user: user,
                                    userRepository: widget.userRepository,
                                    onUserUpdated: (updatedUser) {
                                      final i = _users.indexWhere((u) => u.id == updatedUser.id);
                                      if (i >= 0) {
                                        setState(() {
                                          _users[i] = updatedUser;
                                        });
                                        widget.engine.setUsers(_users);
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                            onQuickCall: () => _openCallSimulation(user),
                          );
                        },
                      ),
              ),
            ],
          ),

          // Tab 2: Full Chronological Timeline Feed
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TimelineLogWidget(logs: widget.engine.logs),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.engine.isRunning) {
            widget.engine.emergencyStop();
          } else {
            widget.engine.runFullSession(simulationSpeed: true);
          }
        },
        backgroundColor: widget.engine.isRunning ? AppColors.statusNoAnswer : AppColors.primary,
        icon: Icon(widget.engine.isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded),
        label: Text(widget.engine.isRunning ? 'إيقاف طارئ' : 'تشغيل الجلسة الآن'),
      ),
    );
  }
}
