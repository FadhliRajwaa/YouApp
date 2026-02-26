import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';

export class LoginDto {
  @ApiProperty({ example: 'john@example.com', description: 'Email or username' })
  @IsString()
  @IsNotEmpty()
  @Transform(({ value }) => value?.trim().toLowerCase())
  usernameOrEmail: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}
