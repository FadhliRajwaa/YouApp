import { Controller, Get, Post, Put, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { CreateProfileDto, UpdateProfileDto } from './dto/profile.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';

@ApiTags('users')
@Controller('api')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post('createProfile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Create profile' })
  @ApiResponse({ status: 201, description: 'Profile has been created' })
  async createProfile(
    @CurrentUser('userId') userId: string,
    @Body() dto: CreateProfileDto,
  ) {
    return this.usersService.createProfile(userId, dto);
  }

  @Get('searchUsers')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Search users by username' })
  @ApiResponse({ status: 200, description: 'Users found' })
  async searchUsers(
    @CurrentUser('userId') userId: string,
    @Query('query') query: string,
  ) {
    if (!query || query.trim().length === 0) return [];
    return this.usersService.searchUsers(query.trim(), userId);
  }

  @Get('getProfile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get profile' })
  @ApiResponse({ status: 200, description: 'Profile found' })
  async getProfile(@CurrentUser('userId') userId: string) {
    return this.usersService.getProfile(userId);
  }

  @Put('updateProfile')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Update profile' })
  @ApiResponse({ status: 200, description: 'Profile has been updated' })
  async updateProfile(
    @CurrentUser('userId') userId: string,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(userId, dto);
  }
}
