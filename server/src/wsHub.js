const WebSocket = require('ws');

// Map of coupleId -> Set of ws clients
const coupleRooms = new Map();

function initWsHub(server) {
  const wss = new WebSocket.Server({ server, path: '/ws' });

  wss.on('connection', (ws, req) => {
    let clientCoupleId = null;
    let clientPartner = null;

    ws.isAlive = true;
    ws.on('pong', () => {
      ws.isAlive = true;
    });

    ws.on('message', (messageRaw) => {
      try {
        const data = JSON.parse(messageRaw);
        const { type, coupleId, partner, payload } = data;

        if (type === 'JOIN_ROOM') {
          clientCoupleId = coupleId;
          clientPartner = partner;
          if (!coupleRooms.has(coupleId)) {
            coupleRooms.set(coupleId, new Set());
          }
          coupleRooms.get(coupleId).add(ws);
          ws.coupleId = coupleId;
          ws.partner = partner;

          console.log(`[WS] Partner '${partner}' joined couple room: ${coupleId}. Clients in room: ${coupleRooms.get(coupleId).size}`);

          // Broadcast presence to room
          broadcastToCouple(coupleId, {
            type: 'PRESENCE_UPDATE',
            sender: partner,
            online: true,
            timestamp: new Date().toISOString()
          }, ws);

          ws.send(JSON.stringify({
            type: 'JOINED_SUCCESS',
            coupleId,
            partner
          }));
        } else if (type === 'INTERACTION_EVENT') {
          // Relaying real-time interactive events (e.g. live hug vibration, animated heart floating, typing)
          if (clientCoupleId) {
            broadcastToCouple(clientCoupleId, {
              type: 'INTERACTION_EVENT',
              sender: clientPartner,
              action: data.action,
              payload: payload || {},
              timestamp: new Date().toISOString()
            }, ws);
          }
        }
      } catch (err) {
        console.error('[WS] Error processing message:', err.message);
      }
    });

    ws.on('close', () => {
      if (clientCoupleId && coupleRooms.has(clientCoupleId)) {
        const room = coupleRooms.get(clientCoupleId);
        room.delete(ws);
        if (room.size === 0) {
          coupleRooms.delete(clientCoupleId);
        } else {
          broadcastToCouple(clientCoupleId, {
            type: 'PRESENCE_UPDATE',
            sender: clientPartner,
            online: false,
            timestamp: new Date().toISOString()
          });
        }
      }
      console.log(`[WS] Client disconnected. Couple: ${clientCoupleId}`);
    });
  });

  // Heartbeat interval
  const interval = setInterval(() => {
    wss.clients.forEach((ws) => {
      if (ws.isAlive === false) return ws.terminate();
      ws.isAlive = false;
      ws.ping();
    });
  }, 30000);

  wss.on('close', () => {
    clearInterval(interval);
  });

  console.log('WebSocket Hub initialized on /ws');
  return wss;
}

function broadcastToCouple(coupleId, message, excludeWs = null) {
  if (!coupleId || !coupleRooms.has(coupleId)) return;
  const room = coupleRooms.get(coupleId);
  const json = JSON.stringify(message);

  room.forEach((client) => {
    if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
      client.send(json);
    }
  });
}

function getRoomStatus(coupleId) {
  if (!coupleRooms.has(coupleId)) return { onlineCount: 0 };
  const room = coupleRooms.get(coupleId);
  return { onlineCount: room.size };
}

module.exports = {
  initWsHub,
  broadcastToCouple,
  getRoomStatus
};
