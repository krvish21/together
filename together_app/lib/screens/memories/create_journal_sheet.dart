import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/together_state.dart';

class CreateJournalSheet extends StatefulWidget {
  const CreateJournalSheet({super.key});

  @override
  State<CreateJournalSheet> createState() => _CreateJournalSheetState();
}

class _CreateJournalSheetState extends State<CreateJournalSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Loved';

  final List<Map<String, String>> _moods = [
    {'mood': 'Loved', 'emoji': '❤️'},
    {'mood': 'Cozy', 'emoji': '☕'},
    {'mood': 'Happy', 'emoji': '😊'},
    {'mood': 'Grateful', 'emoji': '🙏'},
    {'mood': 'Adventurous', 'emoji': '🏕️'},
    {'mood': 'Playful', 'emoji': '✨'},
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
                  const Text('Write Journal Entry 📖', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 14),

              // Mood Selector
              const Text('HOW ARE YOU FEELING?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _moods.map((m) {
                    final isSelected = _selectedMood == m['mood'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text('${m['emoji']} ${m['mood']}'),
                        selected: isSelected,
                        selectedColor: AppTheme.softBlush,
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12,
                        ),
                        onSelected: (_) => setState(() => _selectedMood = m['mood']!),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Entry Title (e.g. Quiet Sunday Reflections)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Write your thoughts, reflections, or notes to each other...'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    final content = _contentController.text.trim();
                    if (title.isNotEmpty && content.isNotEmpty) {
                      final state = Provider.of<TogetherState>(context, listen: false);
                      state.createJournalEntry(
                        title: title,
                        content: content,
                        mood: _selectedMood,
                        tags: [_selectedMood, 'Journal'],
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save to Shared Journal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
