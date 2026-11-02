import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../providers/together_state.dart';

class QuickAffectionBar extends StatelessWidget {
  const QuickAffectionBar({super.key});

  void _showLoveNoteSheet(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Write a Love Note 💌',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Leave something sweet for your partner to see...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) {
                      final state = Provider.of<TogetherState>(context, listen: false);
                      state.sendQuickAffection('note', text);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Send Love Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SPONTANEOUS AFFECTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AffectionButton(
                emoji: '🫂',
                label: 'Send Hug',
                color: const Color(0xFFFFF0F3),
                borderColor: const Color(0xFFFFD1DC),
                onTap: () => state.sendQuickAffection('hug'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AffectionButton(
                emoji: '💋',
                label: 'Send Kiss',
                color: const Color(0xFFFFF5EB),
                borderColor: const Color(0xFFFFE0C2),
                onTap: () => state.sendQuickAffection('kiss'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AffectionButton(
                emoji: '🥺',
                label: 'Miss You',
                color: const Color(0xFFF3EFFF),
                borderColor: const Color(0xFFE2D9FF),
                onTap: () => state.sendQuickAffection('miss_you'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AffectionButton(
                emoji: '💌',
                label: 'Note',
                color: const Color(0xFFE8F9F3),
                borderColor: const Color(0xFFC7F2E2),
                onTap: () => _showLoveNoteSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AffectionButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _AffectionButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }
}
