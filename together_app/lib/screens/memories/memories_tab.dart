import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/together_state.dart';
import 'create_memory_sheet.dart';
import 'create_journal_sheet.dart';

class MemoriesTab extends StatefulWidget {
  const MemoriesTab({super.key});

  @override
  State<MemoriesTab> createState() => _MemoriesTabState();
}

class _MemoriesTabState extends State<MemoriesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final memories = state.memories;
    final journal = state.journalEntries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories & Journal 📸'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryRose,
          unselectedLabelColor: AppTheme.textMuted,
          indicatorColor: AppTheme.primaryRose,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: 'Scrapbook Timeline', icon: Icon(Icons.photo_library_outlined, size: 20)),
            Tab(text: 'Private Journal', icon: Icon(Icons.auto_stories_outlined, size: 20)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateMemorySheet(),
            );
          } else {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const CreateJournalSheet(),
            );
          }
        },
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          _tabController.index == 0 ? 'Add Memory' : 'New Entry',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Scrapbook Timeline
          memories.isEmpty
              ? const Center(
                  child: Text(
                    'Your digital scrapbook is empty.\nTap below to preserve your favorite moments!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    final m = memories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.primaryRose),
                                    const SizedBox(width: 6),
                                    Text(
                                      m.memoryDate,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryRose),
                                    ),
                                  ],
                                ),
                                if (m.location != null && m.location!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(m.location!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              m.title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                            ),
                            if (m.caption != null && m.caption!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                m.caption!,
                                style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.4),
                              ),
                            ],
                            if (m.linkedPlanId != null) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EFFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.link_rounded, size: 14, color: AppTheme.accentPurple),
                                    SizedBox(width: 4),
                                    Text('Linked to Planned Trip/Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentPurple)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // 2. Private Shared Journal
          journal.isEmpty
              ? const Center(
                  child: Text(
                    'No journal reflections yet.\nStart recording your journey together!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  itemCount: journal.length,
                  itemBuilder: (context, index) {
                    final j = journal[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
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
                                    '${j.moodEmoji} ${j.mood.toUpperCase()}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryRose),
                                  ),
                                ),
                                Text(
                                  j.authorPartner == 'partner1'
                                      ? state.couple?.partner1Name ?? 'Partner 1'
                                      : (j.authorPartner == 'partner2' ? state.couple?.partner2Name ?? 'Partner 2' : 'Both ❤️'),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              j.title,
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              j.content,
                              style: const TextStyle(fontSize: 14, color: AppTheme.textDark, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
