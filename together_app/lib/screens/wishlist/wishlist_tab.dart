import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../models/wishlist_model.dart';
import '../../providers/together_state.dart';
import 'add_wishlist_sheet.dart';

class WishlistTab extends StatefulWidget {
  const WishlistTab({super.key});

  @override
  State<WishlistTab> createState() => _WishlistTabState();
}

class _WishlistTabState extends State<WishlistTab> {
  String _selectedCategory = 'All';
  final List<String> _filterCategories = ['All', 'experience', 'place', 'restaurant', 'movie', 'product'];

  void _showConvertDialog(BuildContext context, WishlistModel item) {
    DateTime planDate = DateTime.now().add(const Duration(days: 4));
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Schedule Date Plan 🗓️', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Convert "${item.title}" into an upcoming date plan in your Plans tab!',
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 16),
              const Text('DATE FOR THIS EXPERIENCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: planDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                  );
                  if (picked != null) setDialogState(() => planDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5DFD9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRose, size: 20),
                      const SizedBox(width: 8),
                      Text(DateFormat('EEE, MMM d, yyyy').format(planDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final state = Provider.of<TogetherState>(context, listen: false);
                state.convertWishlistToPlan(
                  item.id,
                  startDate: DateFormat('yyyy-MM-dd').format(planDate),
                  notes: item.notes,
                );
                Navigator.pop(ctx);
              },
              child: const Text('Add to Plans'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final items = state.wishlist.where((w) {
      if (_selectedCategory == 'All') return true;
      return w.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared Wishlist ✨'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const AddWishlistSheet(),
          );
        },
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Wish', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: _filterCategories.map((c) {
                final isSelected = _selectedCategory == c;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(c == 'All' ? 'All' : c.toUpperCase()),
                    selected: isSelected,
                    selectedColor: AppTheme.softBlush,
                    checkmarkColor: AppTheme.primaryRose,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = c),
                  ),
                );
              }).toList(),
            ),
          ),

          // Items List
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Your wishlist is empty.\nTap below to dream up places and experiences together!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isDone = item.isCompleted;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                      color: isDone ? const Color(0xFF06D6A0) : AppTheme.textMuted,
                                      size: 24,
                                    ),
                                    onPressed: () => state.toggleWishlistItem(item.id, !isDone),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(item.categoryIcon, style: const TextStyle(fontSize: 14)),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.categoryLabel.toUpperCase(),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.accentPurple),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            decoration: isDone ? TextDecoration.lineThrough : null,
                                            color: isDone ? AppTheme.textMuted : AppTheme.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (item.notes != null && item.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 44.0),
                                  child: Text(
                                    item.notes!,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              // Interconnected: Turn into Date Plan
                              if (!isDone)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showConvertDialog(context, item),
                                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                                    label: const Text('Schedule Date Plan 🗓️', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppTheme.primaryRose),
                                      foregroundColor: AppTheme.primaryRose,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
