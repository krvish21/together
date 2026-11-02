const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// GET /api/wishlist/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { category, completed } = req.query;

    let sql = 'SELECT * FROM wishlist_items WHERE couple_id = $1';
    const params = [coupleId];

    if (category && category !== 'All') {
      params.push(category);
      sql += ` AND category = $${params.length}`;
    }

    if (completed === 'true') {
      sql += ' AND is_completed = true';
    } else if (completed === 'false') {
      sql += ' AND is_completed = false';
    }

    sql += ' ORDER BY is_completed ASC, created_at DESC';
    const { rows } = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/wishlist/:coupleId
router.post('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { title, category, notes, linkUrl, imageUrl, priority } = req.body;

    if (!title || !category) {
      return res.status(400).json({ error: 'Title and category are required' });
    }

    const itemId = uuidv4();
    await db.query(
      `INSERT INTO wishlist_items (id, couple_id, title, category, notes, link_url, image_url, priority)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        itemId,
        coupleId,
        title,
        category,
        notes || '',
        linkUrl || '',
        imageUrl || '',
        priority || 'medium'
      ]
    );

    const { rows } = await db.query('SELECT * FROM wishlist_items WHERE id = $1', [itemId]);

    broadcastToCouple(coupleId, {
      type: 'WISHLIST_ITEM_ADDED',
      item: rows[0],
      message: `Added to wishlist: "${title}" ✨`
    });

    res.json(rows[0]);
  } catch (err) {
    console.error('Error adding wishlist item:', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/wishlist/:coupleId/:itemId/toggle
router.post('/:coupleId/:itemId/toggle', async (req, res) => {
  try {
    const { coupleId, itemId } = req.params;
    const { isCompleted } = req.body;

    const completedAt = isCompleted ? new Date().toISOString() : null;

    await db.query(
      `UPDATE wishlist_items
       SET is_completed = $1,
           completed_at = $2
       WHERE id = $3 AND couple_id = $4`,
      [isCompleted, completedAt, itemId, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM wishlist_items WHERE id = $1', [itemId]);

    broadcastToCouple(coupleId, {
      type: 'WISHLIST_ITEM_TOGGLED',
      item: rows[0],
      message: isCompleted ? `Checked off wishlist item: "${rows[0].title}"! 🎉` : 'Wishlist item reopened'
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// INTERCONNECTED: Turn Wishlist Item into a Date Plan
// POST /api/wishlist/:coupleId/:itemId/to-plan
router.post('/:coupleId/:itemId/to-plan', async (req, res) => {
  try {
    const { coupleId, itemId } = req.params;
    const { startDate, notes, planType } = req.body;

    const { rows: itemRows } = await db.query('SELECT * FROM wishlist_items WHERE id = $1 AND couple_id = $2', [itemId, coupleId]);
    if (itemRows.length === 0) {
      return res.status(404).json({ error: 'Wishlist item not found' });
    }
    const item = itemRows[0];

    const planId = uuidv4();
    const planDate = startDate || new Date(Date.now() + 86400000 * 3).toISOString().split('T')[0]; // Default 3 days ahead
    const pType = planType || (item.category === 'place' ? 'trip' : 'date');
    const planNotes = `Turned from wishlist item: "${item.title}".\n${notes || item.notes || ''}`;

    await db.query(
      `INSERT INTO plans (id, couple_id, title, plan_type, start_date, notes)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [planId, coupleId, item.title, pType, planDate, planNotes]
    );

    // Link wishlist item to plan
    await db.query(
      'UPDATE wishlist_items SET converted_to_plan_id = $1 WHERE id = $2',
      [planId, itemId]
    );

    const createdPlan = await db.query('SELECT * FROM plans WHERE id = $1', [planId]);

    broadcastToCouple(coupleId, {
      type: 'PLAN_CREATED',
      plan: createdPlan.rows[0],
      message: `Wishlist item "${item.title}" turned into an upcoming ${pType}! 🗓️`
    });

    res.json({
      success: true,
      plan: createdPlan.rows[0]
    });
  } catch (err) {
    console.error('Error converting wishlist to plan:', err);
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/wishlist/:coupleId/:itemId
router.delete('/:coupleId/:itemId', async (req, res) => {
  try {
    const { coupleId, itemId } = req.params;
    await db.query('DELETE FROM wishlist_items WHERE id = $1 AND couple_id = $2', [itemId, coupleId]);

    broadcastToCouple(coupleId, {
      type: 'WISHLIST_ITEM_DELETED',
      itemId
    });

    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
