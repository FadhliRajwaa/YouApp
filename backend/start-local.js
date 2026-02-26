const { MongoMemoryServer } = require('mongodb-memory-server');

async function startLocal() {
  console.log('Starting MongoDB in-memory server...');
  const mongod = await MongoMemoryServer.create();
  const uri = mongod.getUri();
  console.log(`MongoDB in-memory running at: ${uri}`);

  // Set env before importing app
  process.env.MONGODB_URI = uri;
  process.env.JWT_SECRET = process.env.JWT_SECRET || 'youapp-secret-key-2024';
  process.env.JWT_EXPIRATION = process.env.JWT_EXPIRATION || '15m';
  process.env.JWT_REFRESH_SECRET = process.env.JWT_REFRESH_SECRET || 'youapp-refresh-secret-2024';
  process.env.JWT_REFRESH_EXPIRATION = process.env.JWT_REFRESH_EXPIRATION || '7d';
  process.env.RABBITMQ_URI = process.env.RABBITMQ_URI || 'amqp://localhost:5672';

  // Now require the compiled NestJS app
  require('./dist/main');

  // Graceful shutdown
  process.on('SIGINT', async () => {
    console.log('\nShutting down MongoDB in-memory...');
    await mongod.stop();
    process.exit(0);
  });
}

startLocal().catch((err) => {
  console.error('Failed to start:', err);
  process.exit(1);
});
