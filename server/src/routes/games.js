const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { PRESEEDED_GAMES } = require('../seedData');
const { broadcastToCouple } = require('../wsHub');

// GET /api/games/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { rows } = await db.query(
      'SELECT * FROM games WHERE couple_id = $1 ORDER BY updated_at DESC',
      [coupleId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/games/:coupleId/presets
router.get('/:coupleId/presets', (req, res) => {
  res.json(PRESEEDED_GAMES);
});

// POST /api/games/:coupleId/create
router.post('/:coupleId/create', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { gameType, title, gameData, starterPartner } = req.body;

    const gameId = uuidv4();
    const turn = starterPartner === 'partner1' ? 'partner2' : 'partner1';

    await db.query(
      `INSERT INTO games (id, couple_id, game_type, title, current_turn_partner, status, game_data)
       VALUES ($1, $2, $3, $4, $5, 'active', $6)`,
      [gameId, coupleId, gameType, title, turn, JSON.stringify(gameData || {})]
    );

    const { rows } = await db.query('SELECT * FROM games WHERE id = $1', [gameId]);

    broadcastToCouple(coupleId, {
      type: 'GAME_STARTED',
      game: rows[0],
      message: `New game started: ${title}!`
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/games/:coupleId/:gameId/turn
router.post('/:coupleId/:gameId/turn', async (req, res) => {
  try {
    const { coupleId, gameId } = req.params;
    const { partner, moveData } = req.body;

    const { rows } = await db.query(
      'SELECT * FROM games WHERE id = $1 AND couple_id = $2',
      [gameId, coupleId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Game not found' });
    }

    const game = rows[0];
    let data = typeof game.game_data === 'string' ? JSON.parse(game.game_data) : game.game_data;
    let nextTurn = partner === 'partner1' ? 'partner2' : 'partner1';
    let status = 'active';
    let streak = game.streak_count || 0;

    // Handle different game logic
    if (game.game_type === 'would_you_rather') {
      if (partner === 'partner1') {
        data.p1Choice = moveData.choice;
        if (moveData.guess) data.p1GuessP2 = moveData.guess;
      } else {
        data.p2Choice = moveData.choice;
        if (moveData.guess) data.p2GuessP1 = moveData.guess;
      }

      if (data.p1Choice && data.p2Choice) {
        status = 'completed';
        streak += 1;
        nextTurn = 'both';
      }
    } else if (game.game_type === 'this_or_that') {
      const { itemIndex, choice } = moveData;
      if (data.items && data.items[itemIndex]) {
        if (partner === 'partner1') {
          data.items[itemIndex].p1 = choice;
        } else {
          data.items[itemIndex].p2 = choice;
        }
      }
      // Check if all items answered by both
      const allDone = data.items.every(i => i.p1 && i.p2);
      if (allDone) {
        status = 'completed';
        streak += 1;
      }
    } else if (game.game_type === 'guess_my_answer') {
      if (moveData.isAuthorAnswer) {
        data.actualAnswer = moveData.answer;
        nextTurn = partner === 'partner1' ? 'partner2' : 'partner1';
      } else {
        data.partnerGuess = moveData.guess;
        data.revealed = true;
        status = 'completed';
        streak += 1;
      }
    } else if (game.game_type === 'truth_or_dare') {
      if (!data.completedCards) data.completedCards = [];
      data.completedCards.push({
        cardIndex: data.currentCardIndex,
        completedBy: partner,
        proofNote: moveData.proofNote || 'Done with love! ❤️',
        completedAt: new Date().toISOString()
      });
      data.currentCardIndex = ((data.currentCardIndex || 0) + 1) % (data.cards?.length || 1);
      streak += 1;
    } else if (game.game_type === 'who_knows_better') {
      const { questionIndex, answer } = moveData;
      if (data.questions && data.questions[questionIndex]) {
        if (partner === 'partner1') {
          data.questions[questionIndex].p1 = answer;
        } else {
          data.questions[questionIndex].p2 = answer;
        }
      }
      const allDone = data.questions.every(q => q.p1 && q.p2);
      if (allDone) {
        status = 'completed';
        streak += 1;
      }
    }

    await db.query(
      `UPDATE games
       SET game_data = $1,
           current_turn_partner = $2,
           status = $3,
           streak_count = $4,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $5`,
      [JSON.stringify(data), nextTurn, status, streak, gameId]
    );

    const updated = await db.query('SELECT * FROM games WHERE id = $1', [gameId]);
    const updatedGame = updated.rows[0];

    // Broadcast turn or completion
    broadcastToCouple(coupleId, {
      type: status === 'completed' ? 'GAME_COMPLETED' : 'GAME_TURN_PLAYED',
      game: updatedGame,
      partner,
      message: status === 'completed'
        ? `Game "${game.title}" finished! Streak is now ${streak} 🔥`
        : `${partner === 'partner1' ? 'Partner 1' : 'Partner 2'} made a move in "${game.title}"! Your turn! 🎮`
    });

    res.json(updatedGame);
  } catch (err) {
    console.error('Error handling game turn:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
