import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Message, MessageDocument } from './schemas/message.schema';
import { SendMessageDto } from './dto/message.dto';
import { RabbitmqService } from './rabbitmq/rabbitmq.service';

@Injectable()
export class ChatService {
  private readonly logger = new Logger(ChatService.name);

  constructor(
    @InjectModel(Message.name) private messageModel: Model<MessageDocument>,
    private readonly rabbitmqService: RabbitmqService,
  ) {}

  async sendMessage(senderId: string, dto: SendMessageDto): Promise<MessageDocument> {
    const message = await this.messageModel.create({
      senderId: new Types.ObjectId(senderId),
      receiverId: new Types.ObjectId(dto.receiverId),
      content: dto.content,
    });

    // Publish notification to RabbitMQ
    await this.rabbitmqService.publishNotification({
      type: 'new_message',
      senderId,
      receiverId: dto.receiverId,
      content: dto.content,
      messageId: message._id.toString(),
      timestamp: new Date().toISOString(),
    });

    this.logger.log(`Message sent from ${senderId} to ${dto.receiverId}`);
    return message;
  }

  async getMessages(userId: string, otherUserId: string, page = 1, limit = 50): Promise<{ messages: MessageDocument[]; total: number }> {
    const userObjId = new Types.ObjectId(userId);
    const otherObjId = new Types.ObjectId(otherUserId);

    const filter = {
      $or: [
        { senderId: userObjId, receiverId: otherObjId },
        { senderId: otherObjId, receiverId: userObjId },
      ],
    };

    const total = await this.messageModel.countDocuments(filter);
    const skip = (page - 1) * limit;

    const messages = await this.messageModel
      .find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('senderId', 'username name')
      .populate('receiverId', 'username name');

    // Mark messages as read
    await this.messageModel.updateMany(
      { senderId: otherObjId, receiverId: userObjId, isRead: false },
      { isRead: true },
    );

    return { messages: messages.reverse(), total };
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.messageModel.countDocuments({
      receiverId: new Types.ObjectId(userId),
      isRead: false,
    });
  }
}
