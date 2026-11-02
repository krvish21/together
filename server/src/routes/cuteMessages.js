const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../db');
const { broadcastToCouple } = require('../wsHub');

// GET /api/cute-messages/:coupleId
router.get('/:coupleId', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { rows } = await db.query(
      'SELECT * FROM cute_messages WHERE couple_id = $1 ORDER BY created_at DESC LIMIT 50',
      [coupleId]
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/cute-messages/:coupleId/send
router.post('/:coupleId/send', async (req, res) => {
  try {
    const { coupleId } = req.params;
    const { senderPartner, messageType, content, isSurprise, revealAt } = req.body;

    if (!senderPartner || !messageType) {
      return res.status(400).json({ error: 'senderPartner and messageType are required' });
    }

    const messageId = uuidv4();
    const isOpened = !isSurprise;

    await db.query(
      `INSERT INTO cute_messages (id, couple_id, sender_partner, message_type, content, is_surprise, reveal_at, is_opened)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
      [
        messageId,
        coupleId,
        senderPartner,
        messageType,
        content || '',
        isSurprise || false,
        revealAt || null,
        isOpened
      ]
    );

    const { rows } = await db.query('SELECT * FROM cute_messages WHERE id = $1', [messageId]);
    const createdMsg = rows[0];

    // Notification label
    let alertText = 'sent you a love note! 💌';
    if (messageType === 'hug') alertText = 'sent you a tight, warm virtual hug! 🫂';
    else if (messageType === 'kiss') alertText = 'sent you a sweet virtual kiss! 💋';
    else if (messageType === 'miss_you') alertText = 'is missing you right now! 🥺❤️';
    else if (messageType === 'surprise') alertText = 'left you a surprise secret note! 🎁';

    broadcastToCouple(coupleId, {
      type: 'CUTE_MESSAGE_RECEIVED',
      message: createdMsg,
      alertText,
      senderPartner
    });

    res.json(createdMsg);
  } catch (err) {
    console.error('Error sending cute message:', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /api/cute-messages/:coupleId/:messageId/react
router.post('/:coupleId/:messageId/react', async (req, res) => {
  try {
    const { coupleId, messageId } = req.params;
    const { reaction } = req.body;

    await db.query(
      'UPDATE cute_messages SET reaction = $1, is_opened = true WHERE id = $2 AND couple_id = $3',
      [reaction, messageId, coupleId]
    );

    const { rows } = await db.query('SELECT * FROM cute_messages WHERE id = $1', [messageId]);

    broadcastToCouple(coupleId, {
      type: 'CUTE_MESSAGE_REACTED',
      message: rows[0]
    });

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
