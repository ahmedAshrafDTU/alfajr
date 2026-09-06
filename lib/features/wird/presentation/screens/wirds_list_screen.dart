import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

import 'package:alfager/features/wird/presentation/screens/create_wird_screen.dart';

class WirdsListScreen extends StatefulWidget {
  final WirdRepository wirdRepository;

  const WirdsListScreen({super.key, required this.wirdRepository});

  @override
  State<WirdsListScreen> createState() => _WirdsListScreenState();
}

class _WirdsListScreenState extends State<WirdsListScreen> {
  List<Wird> _wirds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWirds();
  }

  Future<void> _loadWirds() async {
    setState(() => _isLoading = true);
    final wirds = await widget.wirdRepository.getAllWirds();
    if (mounted) {
      setState(() {
        _wirds = wirds.where((w) => w.isActive).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الأوراد'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreateWirdScreen(wirdRepository: widget.wirdRepository),
                ),
              );
              if (result == true) {
                _loadWirds();
              }
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _wirds.isEmpty
          ? const Center(child: Text('لا توجد أوراد، اضغط + للإضافة.'))
          : ListView.builder(
              itemCount: _wirds.length,
              itemBuilder: (context, index) {
                final wird = _wirds[index];
                return ListTile(
                  title: Text(wird.title),
                  subtitle: Text('${wird.category} - ${wird.target} ${wird.unit}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await widget.wirdRepository.deleteWird(wird.id);
                      _loadWirds();
                    },
                  ),
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreateWirdScreen(
                          wirdRepository: widget.wirdRepository,
                          wirdToEdit: wird,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadWirds();
                    }
                  },
                );
              },
            ),
    );
  }
}

