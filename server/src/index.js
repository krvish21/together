require('dotenv').config();
const fs = require('fs');
const http = require('http');
const path = require('path');
const express = require('express');
const cors = require('cors');
const { initDb } = require('./db');
const { initWsHub } = require('./wsHub');

const couplesRouter = require('./routes/couples');
const questionsRouter = require('./routes/questions');
const gamesRouter = require('./routes/games');
const plansRouter = require('./routes/plans');
const remindersRouter = require('./routes/reminders');
const cuteMessagesRouter = require('./routes/cuteMessages');
const memoriesRouter = require('./routes/memories');
const journalRouter = require('./routes/journal');
const wishlistRouter = require('./routes/wishlist');
const syncRouter = require('./routes/sync');

const app = express();
const server = http.createServer(app);

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.resolve(__dirname, '../uploads')));

// Routes
app.use('/api/couples', couplesRouter);
app.use('/api/questions', questionsRouter);
app.use('/api/games', gamesRouter);
app.use('/api/plans', plansRouter);
app.use('/api/reminders', remindersRouter);
app.use('/api/cute-messages', cuteMessagesRouter);
app.use('/api/memories', memoriesRouter);
app.use('/api/journal', journalRouter);
app.use('/api/wishlist', wishlistRouter);
app.use('/api/sync', syncRouter);

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    app: 'Together Server',
    database: 'PostgreSQL',
    timestamp: new Date().toISOString()
  });
});

// Serve web app (PWA for iOS / web users)
const publicDir = path.resolve(__dirname, '../public');
if (fs.existsSync(publicDir)) {
  app.use(express.static(publicDir));
  app.use((req, res, next) => {
    if (req.path.startsWith('/api') || req.path.startsWith('/ws') || req.path.startsWith('/uploads')) {
      return next();
    }
    res.sendFile(path.join(publicDir, 'index.html'));
  });
}

const PORT = process.env.PORT || 4000;

async function startServer() {
  try {
    await initDb();
    initWsHub(server);

    server.listen(PORT, '0.0.0.0', () => {
      console.log(`Together Server is running on http://0.0.0.0:${PORT}`);
      console.log(`WebSocket endpoint available at ws://0.0.0.0:${PORT}/ws`);
    });
  } catch (err) {
    console.error('Fatal error starting Together Server:', err);
    process.exit(1);
  }
}

startServer();
