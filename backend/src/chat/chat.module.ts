import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthModule } from '../auth/auth.module';
import { ChatService } from './chat.service';
import { ChatController } from './chat.controller';
import { ChatGateway } from './gateway/chat.gateway';
import { RabbitmqService } from './rabbitmq/rabbitmq.service';
import { Message, MessageSchema } from './schemas/message.schema';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: Message.name, schema: MessageSchema }]),
    AuthModule,
  ],
  controllers: [ChatController],
  providers: [ChatService, ChatGateway, RabbitmqService],
  exports: [ChatService, ChatGateway, RabbitmqService],
})
export class ChatModule {}
