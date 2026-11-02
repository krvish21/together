import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/together_state.dart';

class AddWishlistSheet extends StatefulWidget {
  const AddWishlistSheet({super.key});

  @override
  State<AddWishlistSheet> createState() => _AddWishlistSheetState();
}

class _AddWishlistSheetState extends State<AddWishlistSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _linkController = TextEditingController();
  String _category = 'experience';
  String _priority = 'medium';

  final List<Map<String, String>> _categories = [
    {'cat': 'experience', 'label': 'Experience ✨'},
    {'cat': 'place', 'label': 'Place to Visit ✈️'},
    {'cat': 'restaurant', 'label': 'Restaurant 🍷'},
    {'cat': 'movie', 'label': 'Movie 🎬'},
    {'cat': 'product', 'label': 'Item to Buy 🎁'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add to Wishlist ✨', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 14),

              // Category Selector
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((c) {
                    final isSelected = _category == c['cat'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(c['label']!),
                        selected: isSelected,
                        selectedColor: AppTheme.softBlush,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _category = c['cat']!),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title (e.g. Hot air balloon ride at sunrise)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes or details...'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Link URL (optional)'),
              ),
              const SizedBox(height: 16),

              // Priority
              Row(
                children: [
                  const Text('PRIORITY: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                  const SizedBox(width: 8),
                  ...['low', 'medium', 'high'].map((p) {
                    final isSel = _priority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(p.toUpperCase()),
                        selected: isSel,
                        selectedColor: p == 'high' ? const Color(0xFFFFECEF) : AppTheme.softBlush,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSel ? (p == 'high' ? Colors.red : AppTheme.primaryRose) : AppTheme.textMuted,
                        ),
                        onSelected: (_) => setState(() => _priority = p),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      final state = Provider.of<TogetherState>(context, listen: false);
                      state.addWishlistItem(
                        title: title,
                        category: _category,
                        notes: _notesController.text.trim(),
                        linkUrl: _linkController.text.trim(),
                        priority: _priority,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add to Wishlist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
