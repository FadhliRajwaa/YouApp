import { IsString, IsNumber, IsArray, IsDateString, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProfileDto {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  name: string;

  @ApiProperty({ example: 'Male', required: false })
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiProperty({ example: '1995-08-17' })
  @IsDateString()
  birthday: string;

  @ApiProperty({ example: 175 })
  @IsNumber()
  height: number;

  @ApiProperty({ example: 70 })
  @IsNumber()
  weight: number;

  @ApiProperty({ example: ['Music', 'Sports', 'Travel'] })
  @IsArray()
  @IsString({ each: true })
  interests: string[];
}

export class UpdateProfileDto {
  @ApiProperty({ example: 'John Doe', required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ example: 'Male', required: false })
  @IsOptional()
  @IsString()
  gender?: string;

  @ApiProperty({ example: '1995-08-17', required: false })
  @IsOptional()
  @IsDateString()
  birthday?: string;

  @ApiProperty({ example: 175, required: false })
  @IsOptional()
  @IsNumber()
  height?: number;

  @ApiProperty({ example: 70, required: false })
  @IsOptional()
  @IsNumber()
  weight?: number;

  @ApiProperty({ example: ['Music', 'Sports'], required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  interests?: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  profileImage?: string;
}
