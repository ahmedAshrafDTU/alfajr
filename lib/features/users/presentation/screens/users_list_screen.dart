import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_model.dart';
import '../widgets/user_card.dart';
import 'add_edit_user_screen.dart';
import 'user_detail_screen.dart';

class UsersListScreen extends StatefulWidget {
  final UserRepository userRepository;

  const UsersListScreen({super.key, required this.userRepository});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<UserModel> _users = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final list = await widget.userRepository.getUsers();
    if (mounted) {
      setState(() {
        _users = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      if (_searchQuery.isEmpty) return true;
      return u.name.contains(_searchQuery) || u.phone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navUsers),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'إضافة مشترك جديد',
            onPressed: () async {
              final created = await Navigator.of(context).push<UserModel>(
                MaterialPageRoute(
                  builder: (_) => AddEditUserScreen(userRepository: widget.userRepository),
                ),
              );
              if (created != null) {
                _loadUsers();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'البحث بالاسم أو رقم الهاتف...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  ),
                ),

                // Users Count Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إجمالي المشتركين (${filtered.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'مرتب حسب الأولوية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('لا يوجد مشتركون مطابقون للبحث'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final user = filtered[index];
                            return UserCard(
                              user: user,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => UserDetailScreen(
                                      user: user,
                                      userRepository: widget.userRepository,
                                    ),
                                  ),
                                );
                                _loadUsers();
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push<UserModel>(
            MaterialPageRoute(
              builder: (_) => AddEditUserScreen(userRepository: widget.userRepository),
            ),
          );
          if (created != null) {
            _loadUsers();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded),
      ),
    );
  }
}
