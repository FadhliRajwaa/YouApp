import { IsEmail, IsNotEmpty, IsString, MinLength, MaxLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';

export class RegisterDto {
  @ApiProperty({ example: 'john@example.com' })
  @IsEmail()
  @IsNotEmpty()
  @MaxLength(255)
  @Transform(({ value }) => value?.trim().toLowerCase())
  email: string;

  @ApiProperty({ example: 'johndoe' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  @Matches(/^[a-zA-Z0-9_]+$/, { message: 'Username can only contain letters, numbers and underscores' })
  @Transform(({ value }) => value?.trim().toLowerCase())
  username: string;

  @ApiProperty({ example: 'password123', minLength: 6, maxLength: 72 })
  @IsString()
  @MinLength(6)
  @MaxLength(72)
  password: string;
}
