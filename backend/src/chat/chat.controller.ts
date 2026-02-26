import { Controller, Post, Get, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { SendMessageDto, ViewMessagesDto } from './dto/message.dto';
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
    return { message: 'Message sent successfully', data: message };
  }

  @Get('viewMessages')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'View messages with another user' })
  @ApiQuery({ name: 'page', required: false, description: 'Page number (default: 1)' })
  @ApiQuery({ name: 'limit', required: false, description: 'Messages per page (default: 50, max: 100)' })
  @ApiResponse({ status: 200, description: 'Messages retrieved' })
  async viewMessages(
    @CurrentUser('userId') userId: string,
    @Query() query: ViewMessagesDto,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const pageNum = Math.max(1, parseInt(page || '1', 10) || 1);
    const limitNum = Math.min(100, Math.max(1, parseInt(limit || '50', 10) || 50));
    const result = await this.chatService.getMessages(userId, query.receiverId, pageNum, limitNum);
    return { data: result.messages, total: result.total, page: pageNum, limit: limitNum };
  }

  @Get('unreadCount')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get total unread messages count' })
  @ApiResponse({ status: 200, description: 'Unread count retrieved' })
  async getUnreadCount(@CurrentUser('userId') userId: string) {
    const count = await this.chatService.getUnreadCount(userId);
    return { data: { unreadCount: count } };
  }
}
