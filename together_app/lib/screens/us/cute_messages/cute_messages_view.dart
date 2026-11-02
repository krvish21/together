import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_theme.dart';
import '../../../models/cute_message_model.dart';
import '../../../providers/together_state.dart';

class CuteMessagesView extends StatelessWidget {
  const CuteMessagesView({super.key});

  void _showSurpriseScheduler(BuildContext context) {
    final noteController = TextEditingController();
    DateTime revealDate = DateTime.now().add(const Duration(hours: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Schedule Surprise Note 🎁', style: TextStyle(fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This message remains sealed in a gift box until the unlock time!',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Your secret sweet surprise...'),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.timer_outlined, color: AppTheme.primaryRose),
                title: const Text('Unlock in 3 Hours', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('h:mm a, MMM d').format(revealDate), style: const TextStyle(fontSize: 12)),
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
                final text = noteController.text.trim();
                if (text.isNotEmpty) {
                  final state = Provider.of<TogetherState>(context, listen: false);
                  state.sendQuickAffection('surprise', text);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Seal Gift Box 🎁'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final messages = state.cuteMessages;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSurpriseScheduler(context),
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.card_giftcard_rounded),
        label: const Text('Surprise Note', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Big Affection Action Center
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.romanticGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Instant Affection Studio',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to trigger immediate love pulse on ${state.partnerDisplayName}\'s phone',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _bigAffectionBtn(
                        emoji: '🫂',
                        label: 'Virtual Hug',
                        onTap: () => state.sendQuickAffection('hug'),
                      ),
                      _bigAffectionBtn(
                        emoji: '💋',
                        label: 'Sweet Kiss',
                        onTap: () => state.sendQuickAffection('kiss'),
                      ),
                      _bigAffectionBtn(
                        emoji: '🥺',
                        label: 'Miss You',
                        onTap: () => state.sendQuickAffection('miss_you'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'AFFECTION TIMELINE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            if (messages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text('No affection messages yet. Send a virtual hug above! 🫂', style: TextStyle(color: AppTheme.textMuted)),
                ),
              )
            else
              ...messages.map((m) {
                final isMe = m.senderPartner == state.myRole;
                return _buildMessageCard(m, isMe, state);
              }),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _bigAffectionBtn({required String emoji, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(CuteMessageModel msg, bool isMe, TogetherState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.softBlush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(msg.typeIcon, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMe ? 'You sent ${msg.typeTitle}' : '${state.partnerDisplayName} sent ${msg.typeTitle}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark),
                    ),
                    if (msg.createdAt != null)
                      Text(
                        DateFormat('h:mm a').format(msg.createdAt!),
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                  ],
                ),
                if (msg.content != null && msg.content!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    msg.content!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
