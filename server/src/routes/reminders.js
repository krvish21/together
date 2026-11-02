const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// GET /api/reminders/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { rows } = await db.query(
      'SELECT * FROM reminders WHERE couple_id = $1 ORDER BY is_completed ASC, scheduled_at ASC, created_at DESC',
      [coupleId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/reminders/:coupleId
router.post('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { title, note, scheduledAt, isRecurring, recurrenceRule, assignedTo, style } = req.body;

    if (!title) {
      return res.status(400).json({ error: 'Title is required' });
    }

    const reminderId = uuidv4();
    await db.query(
      `INSERT INTO reminders (id, couple_id, title, note, scheduled_at, is_recurring, recurrence_rule, assigned_to, style)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        reminderId,
        coupleId,
        title,
        note || '',
        scheduledAt || new Date().toISOString(),
        isRecurring || false,
        recurrenceRule || 'none',
        assignedTo || 'both',
        style || 'gentle'
      ]
    );

    const { rows } = await db.query('SELECT * FROM reminders WHERE id = $1', [reminderId]);

    broadcastToCouple(coupleId, {
      type: 'REMINDER_ADDED',
      reminder: rows[0],
      message: `New reminder: "${title}" ⏰`
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/reminders/:coupleId/:reminderId/toggle
router.post('/:coupleId/:reminderId/toggle', async (req, res) => {
  try {
    const { coupleId, reminderId } = req.params;
    const { isCompleted, reaction } = req.body;

    const completedAt = isCompleted ? new Date().toISOString() : null;

    await db.query(
      `UPDATE reminders
       SET is_completed = $1,
           completed_at = $2,
           reaction = COALESCE($3, reaction)
       WHERE id = $4 AND couple_id = $5`,
      [isCompleted, completedAt, reaction, reminderId, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM reminders WHERE id = $1', [reminderId]);

    broadcastToCouple(coupleId, {
      type: 'REMINDER_TOGGLED',
      reminder: rows[0],
      message: isCompleted ? `Reminder completed! ${reaction || '✔️'}` : 'Reminder reopened'
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/reminders/:coupleId/:reminderId
router.delete('/:coupleId/:reminderId', async (req, res) => {
  try {
    const { coupleId, reminderId } = req.params;
    await db.query('DELETE FROM reminders WHERE id = $1 AND couple_id = $2', [reminderId, coupleId]);

    broadcastToCouple(coupleId, {
      type: 'REMINDER_DELETED',
      reminderId
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
