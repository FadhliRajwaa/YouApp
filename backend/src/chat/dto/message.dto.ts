import { IsString, IsNotEmpty, IsMongoId, IsOptional, IsInt, Min, Max } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SendMessageDto {
  @ApiProperty({ example: '507f1f77bcf86cd799439011' })
  @IsMongoId()
  @IsNotEmpty()
  receiverId: string;

  @ApiProperty({ example: 'Hello, how are you?' })
  @IsString()
  @IsNotEmpty()
  content: string;
}

export class ViewMessagesDto {
  @ApiProperty({ example: '507f1f77bcf86cd799439011' })
  @IsMongoId()
  @IsNotEmpty()
  receiverId: string;
}

export class PaginationQueryDto {
  @ApiProperty({ example: 1, required: false, default: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiProperty({ example: 50, required: false, default: 50 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;
}
