import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../models/game_model.dart';
import '../../../providers/together_state.dart';

class GamePlayScreen extends StatefulWidget {
  final GameModel game;

  const GamePlayScreen({super.key, required this.game});

  @override
  State<GamePlayScreen> createState() => _GamePlayScreenState();
}

class _GamePlayScreenState extends State<GamePlayScreen> {
  // State for Would You Rather
  String? _selectedChoice;
  String? _guessedPartnerChoice;

  // State for Guess My Answer
  final _textAnswerController = TextEditingController();

  // State for Truth or Dare
  final _proofNoteController = TextEditingController(text: 'Completed with lots of love! ❤️');

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    // Find updated game instance in state
    final game = state.games.firstWhere((g) => g.id == widget.game.id, orElse: () => widget.game);
    final isMyTurn = game.isMyTurn(state.myRole);
    final isP1 = state.myRole == 'partner1';

    return Scaffold(
      appBar: AppBar(
        title: Text(game.title),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'Streak: ${game.streakCount} 🔥',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Badge
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
                      '${game.gameTypeIcon} ${game.gameTypeLabel.toUpperCase()}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryRose),
                    ),
                  ),
                  Text(
                    game.status == 'completed'
                        ? 'Completed 🎉'
                        : (isMyTurn ? '👉 Your Turn' : '⏳ Waiting for ${state.partnerDisplayName}'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isMyTurn ? AppTheme.primaryRose : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Game Specific Rendering
              if (game.gameType == 'would_you_rather')
                _buildWouldYouRather(game, isP1, state)
              else if (game.gameType == 'this_or_that')
                _buildThisOrThat(game, isP1, state)
              else if (game.gameType == 'truth_or_dare')
                _buildTruthOrDare(game, state)
              else if (game.gameType == 'guess_my_answer')
                _buildGuessMyAnswer(game, isP1, state)
              else
                _buildGenericGame(game, state),
            ],
          ),
        ),
      ),
    );
  }

  // 1. WOULD YOU RATHER
  Widget _buildWouldYouRather(GameModel game, bool isP1, TogetherState state) {
    final data = game.gameData;
    final prompt = data['question'] ?? 'Would you rather...';
    final optA = data['optionA'] ?? 'Option A';
    final optB = data['optionB'] ?? 'Option B';
    final myChoice = isP1 ? data['p1Choice'] : data['p2Choice'];
    final partnerChoice = isP1 ? data['p2Choice'] : data['p1Choice'];
    final isDone = game.status == 'completed';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
        const SizedBox(height: 18),

        if (!isDone && myChoice == null) ...[
          const Text('1. Pick your choice:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          _choiceCard(
            text: optA,
            isSelected: _selectedChoice == 'A',
            onTap: () => setState(() => _selectedChoice = 'A'),
          ),
          const SizedBox(height: 10),
          _choiceCard(
            text: optB,
            isSelected: _selectedChoice == 'B',
            onTap: () => setState(() => _selectedChoice = 'B'),
          ),
          const SizedBox(height: 18),
          const Text('2. Guess what your partner will choose:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
          const SizedBox(height: 8),
          _choiceCard(
            text: optA,
            isSelected: _guessedPartnerChoice == 'A',
            onTap: () => setState(() => _guessedPartnerChoice = 'A'),
          ),
          const SizedBox(height: 10),
          _choiceCard(
            text: optB,
            isSelected: _guessedPartnerChoice == 'B',
            onTap: () => setState(() => _guessedPartnerChoice = 'B'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedChoice != null && _guessedPartnerChoice != null)
                  ? () {
                      state.playTurn(game.id, {
                        'choice': _selectedChoice,
                        'guess': _guessedPartnerChoice,
                      });
                    }
                  : null,
              child: const Text('Lock in Choices! 🔒'),
            ),
          ),
        ] else if (!isDone) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Text('🔒 Your choice is locked!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  'Waiting for ${state.partnerDisplayName} to pick their answer. Once they do, both answers will be revealed!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ] else ...[
          // Completed & Revealed!
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9F3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC7F2E2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 22)),
                    SizedBox(width: 8),
                    Text('Match Results Revealed!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF06D6A0))),
                  ],
                ),
                const SizedBox(height: 12),
                Text('You picked: ${myChoice == 'A' ? optA : optB}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('${state.partnerDisplayName} picked: ${partnerChoice == 'A' ? optA : optB}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Text(
                  myChoice == partnerChoice ? '💕 Perfect Match! You both chose the exact same thing!' : '✨ Opposites attract! Balance in all things.',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryRose),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _choiceCard({required String text, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softBlush : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : const Color(0xFFE5DFD9),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? AppTheme.primaryRose : AppTheme.textDark)),
      ),
    );
  }

  // 2. THIS OR THAT
  Widget _buildThisOrThat(GameModel game, bool isP1, TogetherState state) {
    final items = (game.gameData['items'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pick your habit or vibe for each:', style: TextStyle(fontSize: 14, color: AppTheme.textMuted)),
        const SizedBox(height: 14),
        ...items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = Map<String, dynamic>.from(entry.value);
          final text = item['item'] ?? '';
          final myAns = isP1 ? item['p1'] : item['p2'];
          final partnerAns = isP1 ? item['p2'] : item['p1'];

          final parts = text.split(' or ');
          final opt1 = parts.isNotEmpty ? parts[0] : 'Left';
          final opt2 = parts.length > 1 ? parts[1].replaceAll('?', '') : 'Right';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myAns == opt1 ? AppTheme.primaryRose : const Color(0xFFF1F1F3),
                          foregroundColor: myAns == opt1 ? Colors.white : AppTheme.textDark,
                          elevation: 0,
                        ),
                        onPressed: () {
                          state.playTurn(game.id, {'itemIndex': idx, 'choice': opt1});
                        },
                        child: Text(opt1, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: myAns == opt2 ? AppTheme.primaryRose : const Color(0xFFF1F1F3),
                          foregroundColor: myAns == opt2 ? Colors.white : AppTheme.textDark,
                          elevation: 0,
                        ),
                        onPressed: () {
                          state.playTurn(game.id, {'itemIndex': idx, 'choice': opt2});
                        },
                        child: Text(opt2, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                if (partnerAns != null) ...[
                  const SizedBox(height: 8),
                  Text('${state.partnerDisplayName} chose: $partnerAns', style: const TextStyle(fontSize: 12, color: AppTheme.accentPurple, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  // 3. TRUTH OR DARE
  Widget _buildTruthOrDare(GameModel game, TogetherState state) {
    final cards = (game.gameData['cards'] as List?) ?? [];
    final currentIdx = game.gameData['currentCardIndex'] ?? 0;
    if (cards.isEmpty) return const Text('No cards available');
    final card = Map<String, dynamic>.from(cards[currentIdx % cards.length]);
    final type = card['type'] ?? 'truth';
    final prompt = card['text'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: type == 'dare' ? AppTheme.sunsetGradient : AppTheme.romanticGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: type == 'dare' ? const Color(0xFFFF7E67) : AppTheme.primaryRose,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.4),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: _proofNoteController,
            style: const TextStyle(color: AppTheme.textDark),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Add a cute proof note or reaction...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.textDark,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              state.playTurn(game.id, {'proofNote': _proofNoteController.text});
              _proofNoteController.clear();
            },
            child: const Text('Mark Done & Next Card! 🎉', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // 4. GUESS MY ANSWER
  Widget _buildGuessMyAnswer(GameModel game, bool isP1, TogetherState state) {
    final data = game.gameData;
    final prompt = data['prompt'] ?? 'Secret prompt';
    final actual = data['actualAnswer'] ?? '';
    final guess = data['partnerGuess'] ?? '';
    final revealed = data['revealed'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(prompt, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 18),
        if (actual.isEmpty) ...[
          const Text('You start! Write your secret answer (hidden from partner):', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          TextField(
            controller: _textAnswerController,
            decoration: const InputDecoration(hintText: 'Enter secret answer...'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final ans = _textAnswerController.text.trim();
              if (ans.isNotEmpty) {
                state.playTurn(game.id, {'isAuthorAnswer': true, 'answer': ans});
              }
            },
            child: const Text('Lock in Secret Answer'),
          ),
        ] else if (!revealed) ...[
          const Text('Secret answer is locked! Now guess what it is:', style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 10),
          TextField(
            controller: _textAnswerController,
            decoration: const InputDecoration(hintText: 'Take your best guess...'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final g = _textAnswerController.text.trim();
              if (g.isNotEmpty) {
                state.playTurn(game.id, {'isAuthorAnswer': false, 'guess': g});
              }
            },
            child: const Text('Submit Guess & Reveal'),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9F3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🎉 Revealed Answers:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 8),
                Text('True Answer: $actual', style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Partner Guess: $guess', style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenericGame(GameModel game, TogetherState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Text('Game in progress!'),
    );
  }
}
