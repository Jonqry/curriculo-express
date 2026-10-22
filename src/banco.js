const { Pool } = require('pg');

// No Neon, use a string de conexão com ?sslmode=require.
const banco = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 5,
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 30000,
});

module.exports = banco;
