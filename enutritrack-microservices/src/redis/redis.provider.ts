import { Provider } from '@nestjs/common';
import * as redis from 'redis';

export const RedisProvider: Provider = {
  provide: 'RedisClient',
  useFactory: () => {
    const client = redis.createClient({
      url: process.env.REDIS_URL || 'redis://localhost:6379',
      password: process.env.REDIS_PASSWORD,
    });

    client.on('error', (err) => console.error('Redis Client Error', err));

    return client;
  },
};
