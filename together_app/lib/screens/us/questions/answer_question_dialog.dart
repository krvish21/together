import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../models/question_model.dart';
import '../../../providers/together_state.dart';

class AnswerQuestionDialog extends StatefulWidget {
  final QuestionModel question;

  const AnswerQuestionDialog({super.key, required this.question});

  @override
  State<AnswerQuestionDialog> createState() => _AnswerQuestionDialogState();
}

class _AnswerQuestionDialogState extends State<AnswerQuestionDialog> {
  final _answerController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    final state = Provider.of<TogetherState>(context, listen: false);
    await state.submitAnswer(widget.question.id, text);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    widget.question.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryRose,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.question.questionText,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your answer is locked and revealed only when both of you have submitted!',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              maxLines: 4,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Speak your heart...',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
