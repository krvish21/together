import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../providers/together_state.dart';
import '../../us/games/game_play_screen.dart';

class ActiveGameNudge extends StatelessWidget {
  const ActiveGameNudge({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final games = state.games;
    if (games.isEmpty) return const SizedBox.shrink();

    // Find first active game
    final activeGame = games.firstWhere((g) => g.status == 'active', orElse: () => games.first);
    final isMyTurn = activeGame.isMyTurn(state.myRole);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(activeGame.gameTypeIcon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    activeGame.gameTypeLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (activeGame.streakCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '${activeGame.streakCount} Streak',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            activeGame.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isMyTurn ? const Color(0xFFFFECEF) : const Color(0xFFF1F1F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isMyTurn ? '👉 It\'s your turn!' : '⏳ Waiting for ${state.partnerDisplayName}...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isMyTurn ? AppTheme.primaryRose : AppTheme.textMuted,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GamePlayScreen(game: activeGame)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Play', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
