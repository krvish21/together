const express = require('express');
const router = express.Router();
const path = require('path');
const multer = require('multer');
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// Multer storage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.resolve(__dirname, '../../uploads'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `memory_${Date.now()}_${uuidv4().slice(0, 8)}${ext}`);
  }
});
const upload = multer({ storage });

// POST /api/memories/:coupleId/upload
router.post('/:coupleId/upload', upload.single('photo'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }
  const fileUrl = `/uploads/${req.file.filename}`;
  res.json({ url: fileUrl });
});

// GET /api/memories/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { tag, favoritesOnly } = req.query;

    let sql = 'SELECT * FROM memories WHERE couple_id = $1';
    const params = [coupleId];

    if (favoritesOnly === 'true') {
      sql += ' AND favorite = true';
    }

    sql += ' ORDER BY memory_date DESC, created_at DESC';
    const { rows } = await db.query(sql, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// GET /api/memories/:coupleId/on-this-day
router.get('/:coupleId/on-this-day', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const today = new Date();
    const mm = String(today.getMonth() + 1).padStart(2, '0');
    const dd = String(today.getDate()).padStart(2, '0');
    const todayPattern = `-%-${mm}-${dd}`; // Matches YYYY-MM-DD where MM-DD matches today

    // Fetch all memories and filter for same month/day
    const { rows } = await db.query(
      'SELECT * FROM memories WHERE couple_id = $1 ORDER BY memory_date DESC',
      [coupleId]
    );

    const onThisDay = rows.filter(m => {
      if (!m.memory_date) return false;
      const parts = m.memory_date.split('-');
      if (parts.length >= 3) {
        return parts[1] === mm && parts[2] === dd && parts[0] !== String(today.getFullYear());
      }
      return false;
    });

    res.json(onThisDay);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/memories/:coupleId
router.post('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { title, caption, memoryDate, mediaUrls, location, tags, linkedPlanId, linkedWishlistId } = req.body;

    if (!title || !memoryDate) {
      return res.status(400).json({ error: 'Title and memory date are required' });
    }

    const memoryId = uuidv4();
    await db.query(
      `INSERT INTO memories (id, couple_id, title, caption, memory_date, media_urls, location, tags, linked_plan_id, linked_wishlist_id)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)`,
      [
        memoryId,
        coupleId,
        title,
        caption || '',
        memoryDate,
        JSON.stringify(mediaUrls || []),
        location || '',
        JSON.stringify(tags || []),
        linkedPlanId || null,
        linkedWishlistId || null
      ]
    );

    const { rows } = await db.query('SELECT * FROM memories WHERE id = $1', [memoryId]);

    broadcastToCouple(coupleId, {
      type: 'MEMORY_ADDED',
      memory: rows[0],
      message: `Preserved new memory: "${title}" 📸`
    });

    res.json(rows[0]);
  } catch (err) {
    console.error('Error creating memory:', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/memories/:coupleId/:memoryId/favorite
router.post('/:coupleId/:memoryId/favorite', async (req, res) => {
  try {
    const { coupleId, memoryId } = req.params;
    const { favorite } = req.body;

    await db.query(
      'UPDATE memories SET favorite = $1 WHERE id = $2 AND couple_id = $3',
      [favorite ?? true, memoryId, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM memories WHERE id = $1', [memoryId]);
    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// DELETE /api/memories/:coupleId/:memoryId
router.delete('/:coupleId/:memoryId', async (req, res) => {
  try {
    const { coupleId, memoryId } = req.params;
    await db.query('DELETE FROM memories WHERE id = $1 AND couple_id = $2', [memoryId, coupleId]);
    broadcastToCouple(coupleId, {
      type: 'MEMORY_DELETED',
      memoryId
    });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
