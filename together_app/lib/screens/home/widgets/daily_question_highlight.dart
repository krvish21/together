import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../providers/together_state.dart';
import '../../us/questions/answer_question_dialog.dart';

class DailyQuestionHighlight extends StatelessWidget {
  const DailyQuestionHighlight({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final q = state.dailyQuestion;

    if (q == null) return const SizedBox.shrink();

    final hasMyAnswer = q.hasAnswered(state.myRole);
    final hasPartnerAnswer = q.hasPartnerAnswered(state.myRole);
    final isRevealed = q.isRevealed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlush,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'DAILY QUESTION • ${q.category.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryRose,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              if (isRevealed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F9F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎉 Revealed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF06D6A0))),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Question Prompt
          Text(
            q.questionText,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 16),

          // State Machine View
          if (!hasMyAnswer)
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnswerQuestionDialog(question: q),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('Submit Your Answer'),
                ],
              ),
            )
          else if (!isRevealed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFEAA7)),
              ),
              child: Row(
                children: [
                  const Text('⏳', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'You answered!',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textDark),
                        ),
                        Text(
                          hasPartnerAnswer
                              ? 'Revealing answers...'
                              : 'Answers reveal as soon as ${state.partnerDisplayName} answers!',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // Both Revealed! Show answers & interconnected "Save to Journal" button
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnswerBox(
                  author: state.myDisplayName,
                  answer: q.getMyAnswer(state.myRole) ?? '',
                  color: const Color(0xFFFFF0F3),
                  borderColor: const Color(0xFFFFD1DC),
                ),
                const SizedBox(height: 8),
                _buildAnswerBox(
                  author: state.partnerDisplayName,
                  answer: q.getPartnerAnswer(state.myRole) ?? '',
                  color: const Color(0xFFF3EFFF),
                  borderColor: const Color(0xFFE2D9FF),
                ),
                const SizedBox(height: 12),
                // Interconnected: Convert to Journal
                OutlinedButton.icon(
                  onPressed: () => state.convertQuestionToJournal(q.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                    side: const BorderSide(color: AppTheme.accentPurple),
                    foregroundColor: AppTheme.accentPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.auto_stories_rounded, size: 18),
                  label: const Text('Preserve in Shared Journal 📖', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerBox({
    required String author,
    required String answer,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          ),
        ],
      ),
    );
  }
}
