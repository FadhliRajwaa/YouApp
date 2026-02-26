import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as amqplib from 'amqplib';

const NOTIFICATION_EXCHANGE = 'chat_notifications_fanout';

export interface ChatNotification {
  type: 'new_message';
  senderId: string;
  receiverId: string;
  content: string;
  messageId: string;
  timestamp: string;
}

@Injectable()
export class RabbitmqService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(RabbitmqService.name);
  private connection: amqplib.ChannelModel | null = null;
  private channel: amqplib.Channel | null = null;
  private readonly uri: string;
  private reconnectAttempts = 0;
  private readonly maxReconnectAttempts = 10;
  private isShuttingDown = false;
  private consumerCallback: ((notification: ChatNotification) => void) | null = null;

  constructor(private configService: ConfigService) {
    this.uri = this.configService.get<string>('RABBITMQ_URI') || 'amqp://localhost:5672';
  }

  async onModuleInit() {
    try {
      await this.connect();
      this.logger.log('RabbitMQ connected successfully');
    } catch (error) {
      this.logger.warn(`RabbitMQ connection failed: ${(error as Error).message}. Chat will work without notifications queue.`);
    }
  }

  async onModuleDestroy() {
    this.isShuttingDown = true;
    try {
      if (this.channel) await this.channel.close();
      if (this.connection) await this.connection.close();
    } catch (error) {
      this.logger.error(`Error closing RabbitMQ: ${(error as Error).message}`);
    }
  }

  private async connect() {
    this.connection = await amqplib.connect(this.uri);
    this.channel = await this.connection.createChannel();

    // Use fanout exchange for multi-instance broadcast
    await this.channel.assertExchange(NOTIFICATION_EXCHANGE, 'fanout', { durable: true });

    this.connection.on('error', (err: Error) => {
      this.logger.error(`RabbitMQ connection error: ${err.message}`);
    });

    this.connection.on('close', () => {
      this.logger.warn('RabbitMQ connection closed');
      if (!this.isShuttingDown) {
        this.scheduleReconnect();
      }
    });

    this.reconnectAttempts = 0;
  }

  private scheduleReconnect() {
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.logger.error(`RabbitMQ max reconnection attempts (${this.maxReconnectAttempts}) reached.`);
      return;
    }

    this.reconnectAttempts++;
    const delay = Math.min(1000 * Math.pow(2, this.reconnectAttempts), 30000);
    this.logger.log(`RabbitMQ reconnecting in ${delay}ms (attempt ${this.reconnectAttempts}/${this.maxReconnectAttempts})...`);

    setTimeout(async () => {
      try {
        await this.connect();
        this.logger.log('RabbitMQ reconnected successfully');

        // Re-register consumer if it was set
        if (this.consumerCallback) {
          await this.consumeNotifications(this.consumerCallback);
        }
      } catch (error) {
        this.logger.error(`RabbitMQ reconnection failed: ${(error as Error).message}`);
        this.scheduleReconnect();
      }
    }, delay);
  }

  async publishNotification(notification: ChatNotification): Promise<void> {
    if (!this.channel) {
      this.logger.warn('RabbitMQ channel not available, skipping notification');
      return;
    }

    try {
      this.channel.publish(
        NOTIFICATION_EXCHANGE,
        '',
        Buffer.from(JSON.stringify(notification)),
        { persistent: true },
      );
      this.logger.log(`Notification published for user ${notification.receiverId}`);
    } catch (error) {
      this.logger.error(`Failed to publish notification: ${(error as Error).message}`);
    }
  }

  async consumeNotifications(
    callback: (notification: ChatNotification) => void,
  ): Promise<void> {
    this.consumerCallback = callback;

    if (!this.channel) {
      this.logger.warn('RabbitMQ channel not available, skipping consumer setup');
      return;
    }

    // Each instance gets its own exclusive, auto-delete queue bound to the fanout exchange
    const { queue } = await this.channel.assertQueue('', { exclusive: true, autoDelete: true });
    await this.channel.bindQueue(queue, NOTIFICATION_EXCHANGE, '');

    await this.channel.consume(queue, (msg) => {
      if (msg) {
        try {
          const notification: ChatNotification = JSON.parse(msg.content.toString());
          callback(notification);
        } catch (error) {
          this.logger.error(`Failed to parse notification: ${(error as Error).message}`);
        }
        this.channel!.ack(msg);
      }
    });

    this.logger.log('RabbitMQ notification consumer started');
  }
}
