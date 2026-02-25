import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { ChatService } from './chat.service';
import { RabbitmqService } from './rabbitmq/rabbitmq.service';
import { Message } from './schemas/message.schema';

const USER1_ID = '507f1f77bcf86cd799439011';
const USER2_ID = '507f1f77bcf86cd799439012';

describe('ChatService', () => {
  let service: ChatService;
  let mockMessageModel: any;
  let mockRabbitmqService: any;

  beforeEach(async () => {
    mockMessageModel = {
      create: jest.fn(),
      find: jest.fn().mockReturnValue({
        sort: jest.fn().mockReturnValue({
          populate: jest.fn().mockReturnValue({
            populate: jest.fn().mockResolvedValue([]),
          }),
        }),
      }),
      updateMany: jest.fn().mockResolvedValue({}),
      countDocuments: jest.fn().mockResolvedValue(0),
    };

    mockRabbitmqService = {
      publishNotification: jest.fn().mockResolvedValue(undefined),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        { provide: getModelToken(Message.name), useValue: mockMessageModel },
        { provide: RabbitmqService, useValue: mockRabbitmqService },
      ],
    }).compile();

    service = module.get<ChatService>(ChatService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('sendMessage', () => {
    it('should create a message and publish to RabbitMQ', async () => {
      const mockMessage = {
        _id: { toString: () => 'msg123' },
        senderId: USER1_ID,
        receiverId: USER2_ID,
        content: 'Hello!',
      };
      mockMessageModel.create.mockResolvedValue(mockMessage);

      const result = await service.sendMessage(USER1_ID, {
        receiverId: USER2_ID,
        content: 'Hello!',
      });

      expect(result).toEqual(mockMessage);
      expect(mockMessageModel.create).toHaveBeenCalled();
      expect(mockRabbitmqService.publishNotification).toHaveBeenCalledWith(
        expect.objectContaining({
          type: 'new_message',
          senderId: USER1_ID,
          receiverId: USER2_ID,
          content: 'Hello!',
        }),
      );
    });
  });

  describe('getMessages', () => {
    it('should return messages between two users', async () => {
      const result = await service.getMessages(USER1_ID, USER2_ID);
      expect(result).toEqual([]);
      expect(mockMessageModel.find).toHaveBeenCalled();
    });
  });

  describe('getUnreadCount', () => {
    it('should return unread message count', async () => {
      const count = await service.getUnreadCount(USER1_ID);
      expect(count).toBe(0);
      expect(mockMessageModel.countDocuments).toHaveBeenCalled();
    });
  });
});
