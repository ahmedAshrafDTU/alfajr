class WirdItem {
  final String id;
  final String wirdId;
  final String title;
  final int target; // Used if item has specific count
  final int order;
  
  WirdItem({
    required this.id,
    required this.wirdId,
    required this.title,
    this.target = 1,
    this.order = 0,
  });

  WirdItem copyWith({
    String? id,
    String? wirdId,
    String? title,
    int? target,
    int? order,
  }) {
    return WirdItem(
      id: id ?? this.id,
      wirdId: wirdId ?? this.wirdId,
      title: title ?? this.title,
      target: target ?? this.target,
      order: order ?? this.order,
    );
  }
}
