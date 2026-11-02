const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// GET /api/journal/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { mood, search } = req.query;

    let sql = 'SELECT * FROM journal_entries WHERE couple_id = $1';
    const params = [coupleId];

    if (mood && mood !== 'All') {
      params.push(mood);
      sql += ` AND mood = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      sql += ` AND (title ILIKE $${params.length} OR content ILIKE $${params.length})`;
    }

    sql += ' ORDER BY created_at DESC';
    const { rows } = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/journal/:coupleId
router.post('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { authorPartner, title, content, mood, reflectionPrompt, tags, photos, linkedQuestionId } = req.body;

    if (!title || !content) {
      return res.status(400).json({ error: 'Title and content are required' });
    }

    const entryId = uuidv4();
    await db.query(
      `INSERT INTO journal_entries (id, couple_id, author_partner, title, content, mood, reflection_prompt, tags, photos, linked_question_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        entryId,
        coupleId,
        authorPartner || 'both',
        title,
        content,
        mood || 'Happy',
        reflectionPrompt || null,
        JSON.stringify(tags || []),
        JSON.stringify(photos || []),
        linkedQuestionId || null
      ]
    );

    const { rows } = await db.query('SELECT * FROM journal_entries WHERE id = $1', [entryId]);

    broadcastToCouple(coupleId, {
      type: 'JOURNAL_ENTRY_ADDED',
      entry: rows[0],
      message: 'New shared journal entry written 📖'
    });

    res.json(rows[0]);
  } catch (err) {
    console.error('Error creating journal entry:', err);
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/journal/:coupleId/:entryId
router.delete('/:coupleId/:entryId', async (req, res) => {
  try {
    const { coupleId, entryId } = req.params;
    await db.query('DELETE FROM journal_entries WHERE id = $1 AND couple_id = $2', [entryId, coupleId]);

    broadcastToCouple(coupleId, {
      type: 'JOURNAL_ENTRY_DELETED',
      entryId
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
