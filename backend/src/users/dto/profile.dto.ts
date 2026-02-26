import { IsString, IsNumber, IsArray, IsDateString, IsOptional, Min, Max, MaxLength, ArrayMaxSize } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProfileDto {
  @ApiProperty({ example: 'John Doe' })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiProperty({ example: 'Male', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gender?: string;

  @ApiProperty({ example: '1995-08-17' })
  @IsDateString()
  birthday: string;

  @ApiProperty({ example: 175 })
  @IsNumber()
  @Min(1)
  @Max(300)
  height: number;

  @ApiProperty({ example: 70 })
  @IsNumber()
  @Min(1)
  @Max(500)
  weight: number;

  @ApiProperty({ example: ['Music', 'Sports', 'Travel'] })
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(50, { each: true })
  interests: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  profileImage?: string;
}

export class UpdateProfileDto {
  @ApiProperty({ example: 'John Doe', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  name?: string;

  @ApiProperty({ example: 'Male', required: false })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  gender?: string;

  @ApiProperty({ example: '1995-08-17', required: false })
  @IsOptional()
  @IsDateString()
  birthday?: string;

  @ApiProperty({ example: 175, required: false })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(300)
  height?: number;

  @ApiProperty({ example: 70, required: false })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(500)
  weight?: number;

  @ApiProperty({ example: ['Music', 'Sports'], required: false })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsString({ each: true })
  @MaxLength(50, { each: true })
  interests?: string[];

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  @MaxLength(2048)
  profileImage?: string;
}
