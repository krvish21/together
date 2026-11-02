import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../models/question_model.dart';
import '../../../providers/together_state.dart';
import 'answer_question_dialog.dart';

class QuestionsView extends StatefulWidget {
  const QuestionsView({super.key});

  @override
  State<QuestionsView> createState() => _QuestionsViewState();
}

class _QuestionsViewState extends State<QuestionsView> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Romantic', 'Deep', 'Funny', 'Hypothetical'];

  void _showAddQuestionDialog(BuildContext context) {
    final textController = TextEditingController();
    String category = 'Romantic';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Ask Your Partner', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              DropdownButton<String>(
                value: category,
                isExpanded: true,
                items: ['Romantic', 'Deep', 'Funny', 'Hypothetical']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => category = val);
                },
              ),
              const SizedBox(height: 14),
              const Text('QUESTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'What have you always wanted to ask?'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  final state = Provider.of<TogetherState>(context, listen: false);
                  state.addCustomQuestion(text, category);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Send Question'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final questions = state.questions.where((q) {
      if (_selectedCategory == 'All') return true;
      return q.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionDialog(context),
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ask Question', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppTheme.softBlush,
                    checkmarkColor: AppTheme.primaryRose,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryRose : AppTheme.textDark,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? AppTheme.primaryRose : const Color(0xFFE5DFD9)),
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Questions List
          Expanded(
            child: questions.isEmpty
                ? const Center(
                    child: Text('No questions in this category yet.\nTap below to ask your first question!',
                        textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textMuted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final q = questions[index];
                      return _QuestionCard(question: q);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final QuestionModel question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final hasMyAnswer = question.hasAnswered(state.myRole);
    final hasPartnerAnswer = question.hasPartnerAnswered(state.myRole);
    final isRevealed = question.isRevealed;

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
                    question.category.toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryRose),
                  ),
                ),
                if (isRevealed)
                  const Text('🎉 Both Revealed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF06D6A0)))
                else if (hasMyAnswer)
                  Text('⏳ Waiting for ${state.partnerDisplayName}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))
                else
                  const Text('👉 Your Turn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryRose)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              question.questionText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            const SizedBox(height: 14),
            if (!hasMyAnswer)
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AnswerQuestionDialog(question: question),
                  );
                },
                icon: const Icon(Icons.create_rounded, size: 18),
                label: const Text('Answer to Reveal'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else if (!isRevealed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your answer: "${question.getMyAnswer(state.myRole)}"',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text(
                      hasPartnerAnswer ? 'Revealing answers...' : '🔒 ${state.partnerDisplayName}\'s answer is hidden until they answer!',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('❤️ ${state.myDisplayName}: "${question.getMyAnswer(state.myRole)}"',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EFFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('💙 ${state.partnerDisplayName}: "${question.getPartnerAnswer(state.myRole)}"',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),
                  // Interconnected: Convert to Journal
                  OutlinedButton.icon(
                    onPressed: () => state.convertQuestionToJournal(question.id),
                    icon: const Icon(Icons.auto_stories_rounded, size: 16),
                    label: const Text('Save Conversation to Journal 📖', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 38),
                      side: const BorderSide(color: AppTheme.accentPurple),
                      foregroundColor: AppTheme.accentPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
