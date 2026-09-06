import 'package:flutter/material.dart';
import 'package:alfager/features/wird/domain/entities/wird.dart';
import 'package:alfager/features/wird/domain/entities/wird_item.dart';
import 'package:alfager/features/wird/domain/entities/wird_completion.dart';
import 'package:alfager/features/wird/domain/repositories/wird_repository.dart';

class CurrentWirdScreen extends StatefulWidget {
  final Wird wird;
  final WirdRepository wirdRepository;

  const CurrentWirdScreen({
    super.key,
    required this.wird,
    required this.wirdRepository,
  });

  @override
  State<CurrentWirdScreen> createState() => _CurrentWirdScreenState();
}

class _CurrentWirdScreenState extends State<CurrentWirdScreen> {
  List<WirdItem> _items = [];
  WirdCompletion? _completion;
  bool _isLoading = true;
  Set<String> _checkedItemIds = {};
  int _currentProgress = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final items = await widget.wirdRepository.getWirdItems(widget.wird.id);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    final completion = await widget.wirdRepository.getCompletionForDate(widget.wird.id, todayDate);
    
    if (mounted) {
      setState(() {
        _items = items;
        _completion = completion;
        _isLoading = false;
        if (completion != null) {
          _checkedItemIds = Set.from(completion.completedItemIds);
          _currentProgress = completion.completedValue;
        }
      });
    }
  }

  Future<void> _saveProgress() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    final isFullyCompleted = widget.wird.type == WirdType.checkbox 
        ? _checkedItemIds.length == _items.length 
        : _currentProgress >= widget.wird.target;

    final completion = WirdCompletion(
      id: _completion?.id ?? '${widget.wird.id}_${todayDate.millisecondsSinceEpoch}',
      wirdId: widget.wird.id,
      date: todayDate,
      completedValue: _currentProgress,
      status: isFullyCompleted ? CompletionStatus.completed : CompletionStatus.partial,
      completedAt: isFullyCompleted ? DateTime.now() : null,
      completedItemIds: _checkedItemIds.toList(),
    );

    await widget.wirdRepository.saveCompletion(completion);
    if (mounted) {
      setState(() {
        _completion = completion;
      });
    }
  }

  void _toggleItem(String itemId, bool? value) {
    setState(() {
      if (value == true) {
        _checkedItemIds.add(itemId);
      } else {
        _checkedItemIds.remove(itemId);
      }
      _currentProgress = _checkedItemIds.length;
    });
    _saveProgress();
  }

  void _markAllComplete() {
    setState(() {
      _checkedItemIds = Set.from(_items.map((i) => i.id));
      _currentProgress = widget.wird.type == WirdType.checkbox ? _items.length : widget.wird.target;
    });
    _saveProgress();
    Navigator.of(context).pop(); // Go back after marking all complete
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wird.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'إنجاز الكل',
            onPressed: _markAllComplete,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              _buildHeader(theme),
              Expanded(child: _buildBody()),
              _buildBottomActions(),
            ],
          ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    double progressPercent = 0.0;
    if (widget.wird.type == WirdType.checkbox && _items.isNotEmpty) {
      progressPercent = _checkedItemIds.length / _items.length;
    } else if (widget.wird.target > 0) {
      progressPercent = _currentProgress / widget.wird.target;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          if (widget.wird.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.wird.description,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التقدم',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '${(progressPercent * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercent.clamp(0.0, 1.0),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (widget.wird.type == WirdType.checkbox) {
      if (_items.isEmpty) {
        return const Center(child: Text('لا توجد عناصر لهذا الورد.'));
      }
      return ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          final isChecked = _checkedItemIds.contains(item.id);
          return CheckboxListTile(
            title: Text(
              item.title,
              style: TextStyle(
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? Colors.grey : null,
              ),
            ),
            value: isChecked,
            onChanged: (val) => _toggleItem(item.id, val),
          );
        },
      );
    } else {
      // Counter or duration based
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_currentProgress / ${widget.wird.target}',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Text(widget.wird.unit, style: const TextStyle(fontSize: 20, color: Colors.grey)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(48),
              ),
              onPressed: () {
                if (_currentProgress < widget.wird.target) {
                  setState(() => _currentProgress++);
                  _saveProgress();
                }
              },
              child: const Icon(Icons.add, size: 48),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBottomActions() {
    final isCompleted = _completion?.status == CompletionStatus.completed;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Implement Snooze logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تأجيل الورد.')),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('تأجيل (Snooze)'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: isCompleted ? null : _markAllComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? Colors.green : Theme.of(context).primaryColor,
                ),
                child: Text(isCompleted ? 'تم الإنجاز' : 'إكمال الورد'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
