const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { PRESEEDED_QUESTIONS } = require('../seedData');
const { broadcastToCouple } = require('../wsHub');

// GET /api/questions/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { category, saved } = req.query;

    let sql = 'SELECT * FROM questions WHERE couple_id = $1';
    const params = [coupleId];

    if (category && category !== 'All') {
      params.push(category);
      sql += ` AND category = $${params.length}`;
    }
    if (saved === 'true') {
      sql += ' AND is_saved = true';
    }

    sql += ' ORDER BY created_at DESC';
    const { rows } = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/questions/:coupleId/daily
router.get('/:coupleId/daily', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const today = new Date().toISOString().split('T')[0];

    // Check if daily exists for today
    let { rows } = await db.query(
      'SELECT * FROM questions WHERE couple_id = $1 AND is_daily = true AND daily_date = $2',
      [coupleId, today]
    );

    if (rows.length === 0) {
      // Pick a random question from PRESEEDED_QUESTIONS not asked yet
      const existing = await db.query(
        'SELECT question_text FROM questions WHERE couple_id = $1',
        [coupleId]
      );
      const askedTexts = new Set(existing.rows.map(r => r.question_text));
      const pool = PRESEEDED_QUESTIONS.filter(q => !askedTexts.has(q.text));
      const chosen = pool.length > 0
        ? pool[Math.floor(Math.random() * pool.length)]
        : PRESEEDED_QUESTIONS[Math.floor(Math.random() * PRESEEDED_QUESTIONS.length)];

      const newId = uuidv4();
      await db.query(
        `INSERT INTO questions (id, couple_id, question_text, category, is_daily, daily_date)
         VALUES ($1, $2, $3, $4, true, $5)`,
        [newId, coupleId, chosen.text, chosen.category, today]
      );

      const created = await db.query('SELECT * FROM questions WHERE id = $1', [newId]);
      rows = created.rows;

      broadcastToCouple(coupleId, {
        type: 'NEW_DAILY_QUESTION',
        question: rows[0]
      });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/questions/:coupleId/answer
router.post('/:coupleId/answer', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { questionId, partner, answer } = req.body;

    if (!questionId || !partner || !answer) {
      return res.status(400).json({ error: 'Missing questionId, partner, or answer' });
    }

    const { rows } = await db.query(
      'SELECT * FROM questions WHERE id = $1 AND couple_id = $2',
      [questionId, coupleId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }

    const q = rows[0];
    const now = new Date();

    let p1Ans = q.p1_answer;
    let p2Ans = q.p2_answer;
    let p1Time = q.p1_answered_at;
    let p2Time = q.p2_answered_at;

    if (partner === 'partner1') {
      p1Ans = answer;
      p1Time = now;
    } else {
      p2Ans = answer;
      p2Time = now;
    }

    // Both answered? Reveal!
    const bothAnswered = Boolean(p1Ans && p2Ans);

    await db.query(
      `UPDATE questions
       SET p1_answer = $1,
           p2_answer = $2,
           p1_answered_at = $3,
           p2_answered_at = $4,
           is_revealed = $5
       WHERE id = $6`,
      [p1Ans, p2Ans, p1Time, p2Time, bothAnswered, questionId]
    );

    const updated = await db.query('SELECT * FROM questions WHERE id = $1', [questionId]);
    const updatedQ = updated.rows[0];

    // Broadcast
    if (bothAnswered) {
      broadcastToCouple(coupleId, {
        type: 'QUESTION_REVEALED',
        question: updatedQ,
        message: 'Both partners have answered! Answers are revealed 🎉'
      });
    } else {
      broadcastToCouple(coupleId, {
        type: 'QUESTION_ANSWERED',
        questionId,
        partner,
        message: `${partner === 'partner1' ? 'Partner 1' : 'Partner 2'} answered! Answer yours to reveal ❤️`
      });
    }

    res.json(updatedQ);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/questions/:coupleId/custom
router.post('/:coupleId/custom', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { questionText, category } = req.body;

    if (!questionText) {
      return res.status(400).json({ error: 'Question text is required' });
    }

    const newId = uuidv4();
    await db.query(
      `INSERT INTO questions (id, couple_id, question_text, category, is_daily)
       VALUES ($1, $2, $3, $4, false)`,
      [newId, coupleId, questionText, category || 'Deep']
    );

    const { rows } = await db.query('SELECT * FROM questions WHERE id = $1', [newId]);

    broadcastToCouple(coupleId, {
      type: 'CUSTOM_QUESTION_ADDED',
      question: rows[0]
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/questions/:coupleId/:questionId/save
router.post('/:coupleId/:questionId/save', async (req, res) => {
  try {
    const { questionId, coupleId } = req.params;
    const { isSaved } = req.body;

    await db.query(
      'UPDATE questions SET is_saved = $1 WHERE id = $2 AND couple_id = $3',
      [isSaved ?? true, questionId, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM questions WHERE id = $1', [questionId]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// INTERCONNECTED: Save revealed question as Journal Entry
// POST /api/questions/:coupleId/:questionId/to-journal
router.post('/:coupleId/:questionId/to-journal', async (req, res) => {
  try {
    const { questionId, coupleId } = req.params;
    const { authorPartner } = req.body;

    const qRes = await db.query('SELECT * FROM questions WHERE id = $1 AND couple_id = $2', [questionId, coupleId]);
    if (qRes.rows.length === 0) {
      return res.status(404).json({ error: 'Question not found' });
    }
    const q = qRes.rows[0];

    const coupleRes = await db.query('SELECT * FROM couples WHERE id = $1', [coupleId]);
    const couple = coupleRes.rows[0];
    const p1 = couple.partner1_name || 'Partner 1';
    const p2 = couple.partner2_name || 'Partner 2';

    const journalId = uuidv4();
    const title = `Q&A: ${q.question_text.slice(0, 50)}...`;
    const content = `💬 Question: "${q.question_text}"\n\n` +
      `❤️ ${p1}'s Answer:\n${q.p1_answer || '(No answer)'}\n\n` +
      `💙 ${p2}'s Answer:\n${q.p2_answer || '(No answer)'}`;

    await db.query(
      `INSERT INTO journal_entries (id, couple_id, author_partner, title, content, mood, reflection_prompt, tags, linked_question_id)
       VALUES ($1, $2, $3, $4, $5, 'Loved', $6, $7, $8)`,
      [journalId, coupleId, authorPartner || 'both', title, content, q.question_text, JSON.stringify(['Questions', q.category]), questionId]
    );

    const createdJournal = await db.query('SELECT * FROM journal_entries WHERE id = $1', [journalId]);

    broadcastToCouple(coupleId, {
      type: 'JOURNAL_ENTRY_ADDED',
      entry: createdJournal.rows[0],
      message: 'Saved Q&A conversation to shared Journal!'
    });

    res.json({
      success: true,
      journalEntry: createdJournal.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
