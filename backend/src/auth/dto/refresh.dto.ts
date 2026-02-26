import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RefreshDto {
  @ApiProperty({ description: 'The refresh token received during login' })
  @IsString()
  @IsNotEmpty()
  refresh_token: string;
}
