import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { RabbitmqService } from './rabbitmq.service';

// Mock amqplib
jest.mock('amqplib', () => ({
  connect: jest.fn(),
}));

import * as amqplib from 'amqplib';

describe('RabbitmqService', () => {
  let service: RabbitmqService;
  let mockChannel: any;
  let mockConnection: any;

  beforeEach(async () => {
    mockChannel = {
      assertExchange: jest.fn().mockResolvedValue({}),
      assertQueue: jest.fn().mockResolvedValue({ queue: 'test-queue' }),
      bindQueue: jest.fn().mockResolvedValue({}),
      publish: jest.fn().mockReturnValue(true),
      consume: jest.fn().mockResolvedValue({}),
      ack: jest.fn(),
      close: jest.fn().mockResolvedValue(undefined),
    };

    mockConnection = {
      createChannel: jest.fn().mockResolvedValue(mockChannel),
      on: jest.fn(),
      close: jest.fn().mockResolvedValue(undefined),
    };

    (amqplib.connect as jest.Mock).mockResolvedValue(mockConnection);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RabbitmqService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('amqp://localhost:5672'),
          },
        },
      ],
    }).compile();

    service = module.get<RabbitmqService>(RabbitmqService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should connect to RabbitMQ and assert fanout exchange', async () => {
      await service.onModuleInit();

      expect(amqplib.connect).toHaveBeenCalledWith('amqp://localhost:5672');
      expect(mockConnection.createChannel).toHaveBeenCalled();
      expect(mockChannel.assertExchange).toHaveBeenCalledWith(
        'chat_notifications_fanout',
        'fanout',
        { durable: true },
      );
    });

    it('should handle connection failure gracefully', async () => {
      (amqplib.connect as jest.Mock).mockRejectedValue(new Error('Connection refused'));

      await expect(service.onModuleInit()).resolves.not.toThrow();
    });
  });

  describe('publishNotification', () => {
    it('should publish notification to fanout exchange', async () => {
      await service.onModuleInit();

      const notification = {
        type: 'new_message' as const,
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Hello!',
        messageId: 'msg1',
        timestamp: new Date().toISOString(),
      };

      await service.publishNotification(notification);

      expect(mockChannel.publish).toHaveBeenCalledWith(
        'chat_notifications_fanout',
        '',
        expect.any(Buffer),
        { persistent: true },
      );
    });

    it('should skip publishing when channel is not available', async () => {
      // Don't call onModuleInit so channel is null
      await service.publishNotification({
        type: 'new_message',
        senderId: 'user1',
        receiverId: 'user2',
        content: 'Hello!',
        messageId: 'msg1',
        timestamp: new Date().toISOString(),
      });

      expect(mockChannel.publish).not.toHaveBeenCalled();
    });
  });

  describe('consumeNotifications', () => {
    it('should set up consumer on exclusive queue', async () => {
      await service.onModuleInit();

      const callback = jest.fn();
      await service.consumeNotifications(callback);

      expect(mockChannel.assertQueue).toHaveBeenCalledWith('', {
        exclusive: true,
        autoDelete: true,
      });
      expect(mockChannel.bindQueue).toHaveBeenCalledWith(
        'test-queue',
        'chat_notifications_fanout',
        '',
      );
      expect(mockChannel.consume).toHaveBeenCalled();
    });
  });

  describe('onModuleDestroy', () => {
    it('should close channel and connection', async () => {
      await service.onModuleInit();
      await service.onModuleDestroy();

      expect(mockChannel.close).toHaveBeenCalled();
      expect(mockConnection.close).toHaveBeenCalled();
    });
  });
});
