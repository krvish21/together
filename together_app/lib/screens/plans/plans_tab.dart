import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/together_state.dart';
import 'create_plan_sheet.dart';
import 'plan_detail_screen.dart';

class PlansTab extends StatelessWidget {
  const PlansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final plans = state.plans;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans & Dates 🗓️'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const CreatePlanSheet(),
          );
        },
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Plan', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: plans.isEmpty
          ? const Center(
              child: Text(
                'No upcoming plans yet.\nTap below to plan your next date or trip!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final p = plans[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PlanDetailScreen(plan: p)),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.softBlush,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  p.planType.toUpperCase(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryRose),
                                ),
                              ),
                              Text(p.startDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(p.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          if (p.location != null && p.location!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.primaryRose),
                                const SizedBox(width: 4),
                                Text(p.location!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${p.itinerary.length} Activities • ${p.expenses.length} Expenses', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
