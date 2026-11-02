const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// GET /api/plans/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { rows } = await db.query(
      'SELECT * FROM plans WHERE couple_id = $1 ORDER BY start_date ASC',
      [coupleId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/plans/:coupleId
router.post('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { title, planType, startDate, endDate, location, notes, budget, itinerary, expenses } = req.body;

    if (!title || !startDate) {
      return res.status(400).json({ error: 'Title and start date are required' });
    }

    const planId = uuidv4();
    await db.query(
      `INSERT INTO plans (id, couple_id, title, plan_type, start_date, end_date, location, notes, budget, itinerary, expenses)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)`,
      [
        planId,
        coupleId,
        title,
        planType || 'date',
        startDate,
        endDate || null,
        location || '',
        notes || '',
        budget || 0,
        JSON.stringify(itinerary || []),
        JSON.stringify(expenses || [])
      ]
    );

    const { rows } = await db.query('SELECT * FROM plans WHERE id = $1', [planId]);

    broadcastToCouple(coupleId, {
      type: 'PLAN_CREATED',
      plan: rows[0],
      message: `New plan added: "${title}" on ${startDate} 🗓️`
    });

    res.json(rows[0]);
  } catch (err) {
    console.error('Error creating plan:', err);
    res.status(500).json({ error: err.message });
  }
});

// PUT /api/plans/:coupleId/:planId
router.put('/:coupleId/:planId', async (req, res) => {
  try {
    const { coupleId, planId } = req.params;
    const { title, planType, startDate, endDate, location, notes, budget, itinerary, expenses, isCompleted } = req.body;

    await db.query(
      `UPDATE plans
       SET title = COALESCE($1, title),
           plan_type = COALESCE($2, plan_type),
           start_date = COALESCE($3, start_date),
           end_date = COALESCE($4, end_date),
           location = COALESCE($5, location),
           notes = COALESCE($6, notes),
           budget = COALESCE($7, budget),
           itinerary = COALESCE($8, itinerary),
           expenses = COALESCE($9, expenses),
           is_completed = COALESCE($10, is_completed)
       WHERE id = $11 AND couple_id = $12`,
      [
        title,
        planType,
        startDate,
        endDate,
        location,
        notes,
        budget,
        itinerary ? JSON.stringify(itinerary) : null,
        expenses ? JSON.stringify(expenses) : null,
        isCompleted,
        planId,
        coupleId
      ]
    );

    const { rows } = await db.query('SELECT * FROM plans WHERE id = $1', [planId]);

    broadcastToCouple(coupleId, {
      type: 'PLAN_UPDATED',
      plan: rows[0]
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// INTERCONNECTED: Convert completed plan to Memory
// POST /api/plans/:coupleId/:planId/to-memory
router.post('/:coupleId/:planId/to-memory', async (req, res) => {
  try {
    const { coupleId, planId } = req.params;
    const { caption, photoUrls } = req.body;

    const { rows } = await db.query('SELECT * FROM plans WHERE id = $1 AND couple_id = $2', [planId, coupleId]);
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Plan not found' });
    }
    const plan = rows[0];

    const memoryId = uuidv4();
    const memTitle = `Memory: ${plan.title}`;
    const memCaption = caption || plan.notes || `Remembering our wonderful ${plan.plan_type} on ${plan.start_date}!`;
    const memDate = plan.start_date;
    const memLoc = plan.location || '';
    const memTags = [plan.plan_type, 'Trip & Date'];

    await db.query(
      `INSERT INTO memories (id, couple_id, title, caption, memory_date, media_urls, location, tags, linked_plan_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
      [
        memoryId,
        coupleId,
        memTitle,
        memCaption,
        memDate,
        JSON.stringify(photoUrls || []),
        memLoc,
        JSON.stringify(memTags),
        planId
      ]
    );

    // Also mark plan completed
    await db.query('UPDATE plans SET is_completed = true WHERE id = $1', [planId]);

    const createdMem = await db.query('SELECT * FROM memories WHERE id = $1', [memoryId]);

    broadcastToCouple(coupleId, {
      type: 'MEMORY_ADDED',
      memory: createdMem.rows[0],
      message: `Preserved "${plan.title}" as a forever memory! 📸`
    });

    res.json({
      success: true,
      memory: createdMem.rows[0]
    });
  } catch (err) {
    console.error('Error converting plan to memory:', err);
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/plans/:coupleId/:planId
router.delete('/:coupleId/:planId', async (req, res) => {
  try {
    const { coupleId, planId } = req.params;
    await db.query('DELETE FROM plans WHERE id = $1 AND couple_id = $2', [planId, coupleId]);
    broadcastToCouple(coupleId, {
      type: 'PLAN_DELETED',
      planId
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
