import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_theme.dart';
import '../../models/plan_model.dart';
import '../../providers/together_state.dart';

class PlanDetailScreen extends StatefulWidget {
  final PlanModel plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  void _addItineraryItem(BuildContext context, PlanModel currentPlan) {
    final titleController = TextEditingController();
    final timeController = TextEditingController(text: '7:00 PM');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Activity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time (e.g. 7:30 PM)')),
            const SizedBox(height: 10),
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Activity (e.g. Watch sunset at cliffs)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newItem = ItineraryItem(
                  id: const Uuid().v4(),
                  time: timeController.text.trim(),
                  title: titleController.text.trim(),
                );
                final updatedList = [...currentPlan.itinerary, newItem];
                final state = Provider.of<TogetherState>(context, listen: false);
                state.createPlan(
                  title: currentPlan.title,
                  planType: currentPlan.planType,
                  startDate: currentPlan.startDate,
                  itinerary: updatedList.map((i) => i.toJson()).toList(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addExpenseItem(BuildContext context, PlanModel currentPlan) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String paidBy = 'split';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Expense (e.g. Tickets / Dinner)')),
              const SizedBox(height: 10),
              TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (\$)')),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: paidBy,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'split', child: Text('Split 50/50 🤝')),
                  DropdownMenuItem(value: 'partner1', child: Text('Paid by Partner 1 👤')),
                  DropdownMenuItem(value: 'partner2', child: Text('Paid by Partner 2 👤')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => paidBy = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                if (titleController.text.trim().isNotEmpty && amt > 0) {
                  final newExp = ExpenseItem(
                    id: const Uuid().v4(),
                    title: titleController.text.trim(),
                    amount: amt,
                    paidBy: paidBy,
                  );
                  final updatedList = [...currentPlan.expenses, newExp];
                  final state = Provider.of<TogetherState>(context, listen: false);
                  state.createPlan(
                    title: currentPlan.title,
                    planType: currentPlan.planType,
                    startDate: currentPlan.startDate,
                    expenses: updatedList.map((e) => e.toJson()).toList(),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final plan = state.plans.firstWhere((p) => p.id == widget.plan.id, orElse: () => widget.plan);

    return Scaffold(
      appBar: AppBar(
        title: Text(plan.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_camera_rounded, color: AppTheme.primaryRose),
            tooltip: 'Preserve as Memory',
            onPressed: () {
              state.convertPlanToMemory(plan.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preserved in Memories scrapbook! 📸')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Meta Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.romanticGradient,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          plan.planType.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                        ),
                      ),
                      Text(plan.startDate, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(plan.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                  if (plan.location != null && plan.location!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(plan.location!, style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interconnected Action Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2D9FF)),
              ),
              child: Row(
                children: [
                  const Text('📸', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Done with this date or trip?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('1-tap converts this plan into a permanent scrapbook memory!', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => state.convertPlanToMemory(plan.id),
                    child: const Text('Preserve', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Itinerary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ITINERARY ACTIVITIES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted)),
                IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose), onPressed: () => _addItineraryItem(context, plan)),
              ],
            ),
            if (plan.itinerary.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text('No activities scheduled yet. Tap + to add items!', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              )
            else
              ...plan.itinerary.map((i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.cardBorder)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppTheme.softBlush, borderRadius: BorderRadius.circular(8)),
                        child: Text(i.time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryRose)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(i.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 20),

            // Expenses & Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EXPENSES (TOTAL: \$${plan.totalExpenses.toStringAsFixed(2)})',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
                ),
                IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose), onPressed: () => _addExpenseItem(context, plan)),
              ],
            ),
            if (plan.expenses.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('No expenses recorded yet.', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
              )
            else
              ...plan.expenses.map((e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.cardBorder)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('\$${e.amount.toStringAsFixed(2)} (${e.paidBy})', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryRose)),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
