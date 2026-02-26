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
import { Logger, UsePipes, ValidationPipe } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Server, Socket } from 'socket.io';
import { ChatService } from '../chat.service';
import { RabbitmqService } from '../rabbitmq/rabbitmq.service';
import { SendMessageDto } from '../dto/message.dto';

@WebSocketGateway({ cors: { origin: '*' } })
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect, OnGatewayInit {
  @WebSocketServer() server: Server;
  private readonly logger = new Logger(ChatGateway.name);
  private connectedUsers = new Map<string, Set<string>>(); // userId -> Set<socketId>
  private socketToUser = new Map<string, string>(); // socketId -> userId

  constructor(
    private readonly chatService: ChatService,
    private readonly rabbitmqService: RabbitmqService,
    private readonly jwtService: JwtService,
  ) {}

  async afterInit() {
    await this.rabbitmqService.consumeNotifications((notification) => {
      this.logger.log(`RabbitMQ notification received for user ${notification.receiverId}`);
      this.notifyUser(notification.receiverId, 'newMessage', {
        type: notification.type,
        message: 'You have a new message',
        data: notification,
      });
    });
  }

  handleConnection(client: Socket) {
    try {
      const token =
        (client.handshake.auth?.token as string) ||
        (client.handshake.headers?.authorization?.replace('Bearer ', '') as string);

      if (!token) {
        this.logger.warn(`Client ${client.id} connected without token`);
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);
      const userId = payload.sub;

      if (!this.connectedUsers.has(userId)) {
        this.connectedUsers.set(userId, new Set());
      }
      this.connectedUsers.get(userId)!.add(client.id);
      this.socketToUser.set(client.id, userId);

      this.logger.log(`User ${userId} connected with socket ${client.id}`);
    } catch {
      this.logger.warn(`Client ${client.id} failed JWT verification`);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = this.socketToUser.get(client.id);
    if (userId) {
      const sockets = this.connectedUsers.get(userId);
      if (sockets) {
        sockets.delete(client.id);
        if (sockets.size === 0) {
          this.connectedUsers.delete(userId);
        }
      }
      this.socketToUser.delete(client.id);
      this.logger.log(`User ${userId} disconnected (socket ${client.id})`);
    }
  }

  @UsePipes(new ValidationPipe({ whitelist: true }))
  @SubscribeMessage('sendMessage')
  async handleSendMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: SendMessageDto,
  ) {
    const senderId = this.socketToUser.get(client.id);
    if (!senderId) {
      return { error: 'Not authenticated' };
    }

    const message = await this.chatService.sendMessage(senderId, {
      receiverId: data.receiverId,
      content: data.content,
    });

    // RabbitMQ consumer will handle unified notification delivery
    return message;
  }

  notifyUser(userId: string, event: string, data: any) {
    const sockets = this.connectedUsers.get(userId);
    if (sockets) {
      for (const socketId of sockets) {
        this.server.to(socketId).emit(event, data);
      }
    }
  }
}
