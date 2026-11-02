import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../providers/together_state.dart';

class CreatePlanSheet extends StatefulWidget {
  final String? initialTitle;
  final String? initialCategory;
  final String? initialNotes;

  const CreatePlanSheet({
    super.key,
    this.initialTitle,
    this.initialCategory,
    this.initialNotes,
  });

  @override
  State<CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<CreatePlanSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  late final TextEditingController _budgetController;

  String _planType = 'date';
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));

  final List<Map<String, String>> _types = [
    {'type': 'date', 'label': 'Date Night 🍷'},
    {'type': 'trip', 'label': 'Trip / Vacation ✈️'},
    {'type': 'celebration', 'label': 'Celebration 🎉'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _locationController = TextEditingController();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _budgetController = TextEditingController();

    if (widget.initialCategory == 'place') _planType = 'trip';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

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
                  const Text('Plan An Experience 🗓️', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 14),

              // Plan Type Selection
              Row(
                children: _types.map((t) {
                  final isSelected = _planType == t['type'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(t['label']!),
                      selected: isSelected,
                      selectedColor: AppTheme.softBlush,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _planType = t['type']!),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Plan Title (e.g. Sunset Wine & Italian Dinner)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location / Venue'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5DFD9)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryRose, size: 20),
                      const SizedBox(width: 10),
                      Text(DateFormat('EEE, MMM d, yyyy').format(_startDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Estimated Budget (\$ optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes, ideas, or packing tips...'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text.trim();
                    if (title.isNotEmpty) {
                      final state = Provider.of<TogetherState>(context, listen: false);
                      final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;
                      state.createPlan(
                        title: title,
                        planType: _planType,
                        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
                        location: _locationController.text.trim(),
                        notes: _notesController.text.trim(),
                        budget: budget,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Plan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
