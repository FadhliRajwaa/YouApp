import { IsNotEmpty, IsString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';

export class LoginDto {
  @ApiProperty({ example: 'john@example.com', description: 'Email or username (combined field)', required: false })
  @IsString()
  @IsOptional()
  @Transform(({ value }) => value?.trim().toLowerCase())
  usernameOrEmail?: string;

  @ApiProperty({ example: 'john@example.com', description: 'Email address', required: false })
  @IsString()
  @IsOptional()
  @Transform(({ value }) => value?.trim().toLowerCase())
  email?: string;

  @ApiProperty({ example: 'johndoe', description: 'Username', required: false })
  @IsString()
  @IsOptional()
  @Transform(({ value }) => value?.trim().toLowerCase())
  username?: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}
