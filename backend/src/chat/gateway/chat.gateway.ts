import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { ChatService } from '../chat.service';
import { RabbitmqService } from '../rabbitmq/rabbitmq.service';

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit {
  @WebSocketServer() server: Server;
  private readonly logger = new Logger(ChatGateway.name);
  private connectedUsers = new Map<string, string>(); // userId -> socketId

  constructor(
    private readonly chatService: ChatService,
    private readonly rabbitmqService: RabbitmqService,
  ) {}

  async afterInit() {
    // Start consuming RabbitMQ notifications and forward via WebSocket
    await this.rabbitmqService.consumeNotifications((notification) => {
      this.logger.log(`RabbitMQ notification received for user ${notification.receiverId}`);
      this.notifyUser(notification.receiverId, 'notification', {
        type: notification.type,
        message: 'You have a new message',
        data: notification,
      });
    });
  }

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    const userId = [...this.connectedUsers.entries()]
      .find(([, socketId]) => socketId === client.id)?.[0];
    if (userId) {
      this.connectedUsers.delete(userId);
      this.logger.log(`User ${userId} disconnected`);
    }
  }

  @SubscribeMessage('register')
  handleRegister(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { userId: string },
  ) {
    this.connectedUsers.set(data.userId, client.id);
    this.logger.log(`User ${data.userId} registered with socket ${client.id}`);
  }

  @SubscribeMessage('sendMessage')
  async handleSendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { senderId: string; receiverId: string; content: string },
  ) {
    const message = await this.chatService.sendMessage(data.senderId, {
      receiverId: data.receiverId,
      content: data.content,
    });

    // Notify receiver in real-time via WebSocket
    const receiverSocketId = this.connectedUsers.get(data.receiverId);
    if (receiverSocketId) {
      this.server.to(receiverSocketId).emit('newMessage', message);
    }

    return message;
  }

  notifyUser(userId: string, event: string, data: any) {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.server.to(socketId).emit(event, data);
    }
  }
}
