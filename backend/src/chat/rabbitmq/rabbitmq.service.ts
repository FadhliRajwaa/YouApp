import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as amqplib from 'amqplib';

const NOTIFICATION_QUEUE = 'chat_notifications';

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
    await this.channel.assertQueue(NOTIFICATION_QUEUE, { durable: true });

    this.connection.on('error', (err: Error) => {
      this.logger.error(`RabbitMQ connection error: ${err.message}`);
    });

    this.connection.on('close', () => {
      this.logger.warn('RabbitMQ connection closed');
    });
  }

  async publishNotification(notification: ChatNotification): Promise<void> {
    if (!this.channel) {
      this.logger.warn('RabbitMQ channel not available, skipping notification');
      return;
    }

    try {
      this.channel.sendToQueue(
        NOTIFICATION_QUEUE,
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
    if (!this.channel) {
      this.logger.warn('RabbitMQ channel not available, skipping consumer setup');
      return;
    }

    await this.channel.consume(NOTIFICATION_QUEUE, (msg) => {
      if (msg) {
        const notification: ChatNotification = JSON.parse(msg.content.toString());
        callback(notification);
        this.channel!.ack(msg);
      }
    });

    this.logger.log('RabbitMQ notification consumer started');
  }
}
