const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { PRESEEDED_QUESTIONS, PRESEEDED_GAMES } = require('../seedData');
const { broadcastToCouple } = require('../wsHub');

// Helper to generate 6-character space code: LOVE-XXX or TOG-XXX
function generateSpaceCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  let rand = '';
  for (let i = 0; i < 4; i++) {
    rand += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return `LOVE-${rand}`;
}

// POST /api/couples/create
router.post('/create', async (req, res) => {
  try {
    const { partner1Name, anniversaryDate, relationshipStatus, themeColor } = req.body;
    if (!partner1Name) {
      return res.status(400).json({ error: 'Partner name is required' });
    }

    const coupleId = uuidv4();
    const spaceCode = generateSpaceCode();
    const annDate = anniversaryDate || new Date().toISOString().split('T')[0];

    await db.query(
      `INSERT INTO couples (id, space_code, partner1_name, anniversary_date, relationship_status, theme_color)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [coupleId, spaceCode, partner1Name, annDate, relationshipStatus || 'In Love ❤️', themeColor || '#FF6584']
    );

    // Seed initial daily question
    const starterQ = PRESEEDED_QUESTIONS[0];
    const today = new Date().toISOString().split('T')[0];
    await db.query(
      `INSERT INTO questions (id, couple_id, question_text, category, is_daily, daily_date)
       VALUES ($1, $2, $3, $4, true, $5)`,
      [uuidv4(), coupleId, starterQ.text, starterQ.category, today]
    );

    // Seed starter games
    for (const game of PRESEEDED_GAMES.slice(0, 3)) {
      await db.query(
        `INSERT INTO games (id, couple_id, game_type, title, game_data)
         VALUES ($1, $2, $3, $4, $5)`,
        [uuidv4(), coupleId, game.game_type, game.title, JSON.stringify(game.game_data)]
      );
    }

    // Seed welcoming cute message
    await db.query(
      `INSERT INTO cute_messages (id, couple_id, sender_partner, message_type, content)
       VALUES ($1, $2, $3, $4, $5)`,
      [uuidv4(), coupleId, 'partner1', 'note', "Welcome to our private Together space! Let's build beautiful memories ❤️"]
    );

    // Fetch created couple
    const { rows } = await db.query('SELECT * FROM couples WHERE id = $1', [coupleId]);
    res.json({
      success: true,
      couple: rows[0],
      assignedPartner: 'partner1'
    });
  } catch (err) {
    console.error('Error creating couple:', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/couples/join
router.post('/join', async (req, res) => {
  try {
    const { spaceCode, partner2Name } = req.body;
    if (!spaceCode || !partner2Name) {
      return res.status(400).json({ error: 'Space code and your name are required' });
    }

    const cleanCode = spaceCode.trim().toUpperCase();
    const { rows } = await db.query('SELECT * FROM couples WHERE space_code = $1', [cleanCode]);

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Invalid invite code. Please double check with your partner.' });
    }

    const couple = rows[0];
    await db.query(
      'UPDATE couples SET partner2_name = $1 WHERE id = $2',
      [partner2Name, couple.id]
    );

    // Broadcast update
    broadcastToCouple(couple.id, {
      type: 'PARTNER_JOINED',
      partner2Name,
      message: `${partner2Name} joined your Together space!`
    });

    const updated = await db.query('SELECT * FROM couples WHERE id = $1', [couple.id]);
    res.json({
      success: true,
      couple: updated.rows[0],
      assignedPartner: 'partner2'
    });
  } catch (err) {
    console.error('Error joining couple:', err);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/couples/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { rows } = await db.query('SELECT * FROM couples WHERE id = $1', [coupleId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Couple space not found' });
    }
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/couples/:coupleId
router.put('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { partner1Name, partner2Name, anniversaryDate, relationshipStatus, themeColor } = req.body;

    await db.query(
      `UPDATE couples
       SET partner1_name = COALESCE($1, partner1_name),
           partner2_name = COALESCE($2, partner2_name),
           anniversary_date = COALESCE($3, anniversary_date),
           relationship_status = COALESCE($4, relationship_status),
           theme_color = COALESCE($5, theme_color)
       WHERE id = $6`,
      [partner1Name, partner2Name, anniversaryDate, relationshipStatus, themeColor, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM couples WHERE id = $1', [coupleId]);
    broadcastToCouple(coupleId, {
      type: 'COUPLE_PROFILE_UPDATED',
      couple: rows[0]
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
