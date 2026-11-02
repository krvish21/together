const express = require('express');
const router = express.Router();
const db = require('../db');
const { getRoomStatus } = require('../wsHub');

// GET /api/sync/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const today = new Date().toISOString().split('T')[0];

    const [
      coupleRes,
      questionsRes,
      gamesRes,
      plansRes,
      remindersRes,
      cuteRes,
      memoriesRes,
      journalRes,
      wishlistRes
    ] = await Promise.all([
      db.query('SELECT * FROM couples WHERE id = $1', [coupleId]),
      db.query('SELECT * FROM questions WHERE couple_id = $1 ORDER BY created_at DESC', [coupleId]),
      db.query('SELECT * FROM games WHERE couple_id = $1 ORDER BY updated_at DESC', [coupleId]),
      db.query('SELECT * FROM plans WHERE couple_id = $1 ORDER BY start_date ASC', [coupleId]),
      db.query('SELECT * FROM reminders WHERE couple_id = $1 ORDER BY is_completed ASC, scheduled_at ASC, created_at DESC', [coupleId]),
      db.query('SELECT * FROM cute_messages WHERE couple_id = $1 ORDER BY created_at DESC LIMIT 30', [coupleId]),
      db.query('SELECT * FROM memories WHERE couple_id = $1 ORDER BY memory_date DESC, created_at DESC', [coupleId]),
      db.query('SELECT * FROM journal_entries WHERE couple_id = $1 ORDER BY created_at DESC', [coupleId]),
      db.query('SELECT * FROM wishlist_items WHERE couple_id = $1 ORDER BY is_completed ASC, created_at DESC', [coupleId])
    ]);

    if (coupleRes.rows.length === 0) {
      return res.status(404).json({ error: 'Couple space not found' });
    }

    const couple = coupleRes.rows[0];
    const dailyQuestion = questionsRes.rows.find(q => q.is_daily && q.daily_date === today) || null;
    const roomStatus = getRoomStatus(coupleId);

    res.json({
      couple,
      dailyQuestion,
      questions: questionsRes.rows,
      games: gamesRes.rows,
      plans: plansRes.rows,
      reminders: remindersRes.rows,
      cuteMessages: cuteRes.rows,
      memories: memoriesRes.rows,
      journalEntries: journalRes.rows,
      wishlist: wishlistRes.rows,
      roomStatus,
      syncedAt: new Date().toISOString()
    });
  } catch (err) {
    console.error('Sync error:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
