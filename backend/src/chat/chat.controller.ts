import { Controller, Post, Get, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { SendMessageDto } from './dto/message.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('chat')
@Controller('api')
export class ChatController {
  constructor(private readonly chatService: ChatService) {}

  @Post('sendMessage')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Send a message to another user' })
  @ApiResponse({ status: 201, description: 'Message sent successfully' })
  async sendMessage(
    @CurrentUser('userId') userId: string,
    @Body() dto: SendMessageDto,
  ) {
    const message = await this.chatService.sendMessage(userId, dto);
    // Notification is handled via RabbitMQ -> WebSocket in ChatGateway
    return { message: 'Message sent successfully', data: message };
  }

  @Get('viewMessages')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'View messages with another user' })
  @ApiQuery({ name: 'receiverId', description: 'The other user ID' })
  @ApiResponse({ status: 200, description: 'Messages retrieved' })
  async viewMessages(
    @CurrentUser('userId') userId: string,
    @Query('receiverId') receiverId: string,
  ) {
    const messages = await this.chatService.getMessages(userId, receiverId);
    return { data: messages };
  }
}
