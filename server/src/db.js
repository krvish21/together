const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

let pool = null;
let pgliteDb = null;
let isPgLite = false;

async function initDb() {
  if (process.env.DATABASE_URL) {
    console.log('Connecting to PostgreSQL via DATABASE_URL...');
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false
    });
    // Test connection
    const client = await pool.connect();
    console.log('Connected to PostgreSQL successfully');
    client.release();
    isPgLite = false;
  } else {
    console.log('No DATABASE_URL set. Initializing embedded PostgreSQL (PGlite) with disk persistence...');
    const dataDir = path.resolve(__dirname, '../data/together_postgres_db');
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
    const { PGlite } = require('@electric-sql/pglite');
    pgliteDb = new PGlite(dataDir);
    isPgLite = true;
    console.log(`Embedded PostgreSQL running with storage in: ${dataDir}`);
  }

  // Run schema creation
  await runMigrations();
}

async function query(text, params = []) {
  if (isPgLite) {
    const res = await pgliteDb.query(text, params);
    return res;
  } else {
    return await pool.query(text, params);
  }
}

async function exec(text) {
  if (isPgLite) {
    return await pgliteDb.exec(text);
  } else {
    return await pool.query(text);
  }
}

async function runMigrations() {
  const schemaSqlPath = path.resolve(__dirname, 'schema.sql');
  if (fs.existsSync(schemaSqlPath)) {
    const schemaSql = fs.readFileSync(schemaSqlPath, 'utf8');
    console.log('Applying database migrations / schema...');
    await exec(schemaSql);
    console.log('Database schema applied successfully.');
  }
}

module.exports = {
  initDb,
  query,
  exec,
  isPgLite: () => isPgLite
};
