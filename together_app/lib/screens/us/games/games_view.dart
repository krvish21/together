import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../providers/together_state.dart';
import 'game_play_screen.dart';

class GamesView extends StatelessWidget {
  const GamesView({super.key});

  void _showCreateGameSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start a New Turn-Based Game 🎮',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Play casual games asynchronously throughout the day.',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 18),
            _buildGameOption(
              ctx,
              context,
              title: 'Would You Rather?',
              emoji: '🤔',
              desc: 'Compare choices and see if you can guess each other\'s pick!',
              type: 'would_you_rather',
              data: {
                'question': 'Would you rather have...',
                'optionA': 'A cozy rain day with hot cocoa and cuddles',
                'optionB': 'A sunny afternoon exploring a secret antique market',
                'round': 1,
              },
            ),
            _buildGameOption(
              ctx,
              context,
              title: 'This or That',
              emoji: '⚖️',
              desc: 'Rapid fire habit checks (Coffee vs Tea, Early Bird vs Night Owl).',
              type: 'this_or_that',
              data: {
                'items': [
                  {'item': 'Spontaneous trip or Detailed plan?', 'p1': null, 'p2': null},
                  {'item': 'Sweet dessert or Savory snack?', 'p1': null, 'p2': null},
                  {'item': 'Sunset beach or Snowy mountain?', 'p1': null, 'p2': null},
                ],
              },
            ),
            _buildGameOption(
              ctx,
              context,
              title: 'Truth or Dare',
              emoji: '🎭',
              desc: 'Fun prompts and affectionate challenges with proof notes.',
              type: 'truth_or_dare',
              data: {
                'cards': [
                  {'type': 'truth', 'text': 'What was your absolute favorite moment with me this month?'},
                  {'type': 'dare', 'text': 'Send a photo right now with your biggest, happiest smile!'},
                  {'type': 'truth', 'text': 'If you had to describe our relationship in 3 words, what are they?'},
                ],
                'currentCardIndex': 0,
                'completedCards': [],
              },
            ),
            _buildGameOption(
              ctx,
              context,
              title: 'Guess My Answer',
              emoji: '🎯',
              desc: 'Write a secret answer and see if your partner can guess it correctly.',
              type: 'guess_my_answer',
              data: {
                'prompt': 'What song immediately makes me think of you whenever I hear it?',
                'actualAnswer': '',
                'partnerGuess': '',
                'revealed': false,
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOption(
    BuildContext sheetCtx,
    BuildContext rootCtx, {
    required String title,
    required String emoji,
    required String desc,
    required String type,
    required Map<String, dynamic> data,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.softBlush,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      onTap: () {
        Navigator.pop(sheetCtx);
        final state = Provider.of<TogetherState>(rootCtx, listen: false);
        state.createGame(type, title, data);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final games = state.games;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGameSheet(context),
        backgroundColor: AppTheme.accentPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.videogame_asset_rounded),
        label: const Text('Start Game', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final isMyTurn = game.isMyTurn(state.myRole);
          final isDone = game.status == 'completed';

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GamePlayScreen(game: game)),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFFF1F1F3) : AppTheme.softBlush,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: Text(game.gameTypeIcon, style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                game.gameTypeLabel,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.accentPurple),
                              ),
                              if (game.streakCount > 0) ...[
                                const SizedBox(width: 6),
                                Text('🔥 ${game.streakCount}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFE65100))),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isDone
                                ? 'Completed round'
                                : (isMyTurn ? '👉 Your turn!' : '⏳ Waiting for ${state.partnerDisplayName}'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDone
                                  ? AppTheme.textMuted
                                  : (isMyTurn ? AppTheme.primaryRose : AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
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
