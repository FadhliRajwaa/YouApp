import { Injectable, ConflictException, UnauthorizedException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from '../users/schemas/user.schema';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
  private readonly refreshSecret: string;
  private readonly refreshExpiration: string;

  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {
    this.refreshSecret =
      this.configService.get<string>('JWT_REFRESH_SECRET') ||
      this.configService.getOrThrow<string>('JWT_SECRET') + '-refresh';
    this.refreshExpiration =
      this.configService.get<string>('JWT_REFRESH_EXPIRATION', '7d');
  }

  async register(registerDto: RegisterDto): Promise<{ message: string }> {
    const email = registerDto.email.trim().toLowerCase();
    const username = registerDto.username.trim().toLowerCase();

    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    try {
      await this.userModel.create({
        email,
        username,
        password: hashedPassword,
      });
    } catch (error: any) {
      if (error.code === 11000) {
        throw new ConflictException('Email or username already exists');
      }
      throw error;
    }

    return { message: 'User has been created successfully' };
  }

  async login(loginDto: LoginDto): Promise<{
    access_token: string;
    refresh_token: string;
    userId: string;
  }> {
    const identifier = loginDto.usernameOrEmail;

    const user = await this.userModel.findOne({
      $or: [
        { email: identifier },
        { username: identifier },
      ],
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const userId = user._id.toString();
    const payload = { sub: userId, email: user.email, username: user.username };

    return {
      access_token: this.jwtService.sign(payload),
      refresh_token: this.generateRefreshToken(userId),
      userId,
    };
  }

  async refresh(refreshToken: string): Promise<{ access_token: string }> {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.refreshSecret,
      });

      if (payload.type !== 'refresh') {
        throw new UnauthorizedException('Invalid token type');
      }

      // Verify user still exists
      const user = await this.userModel.findById(payload.sub).select('email username');
      if (!user) {
        throw new UnauthorizedException('User no longer exists');
      }

      const newPayload = {
        sub: user._id.toString(),
        email: user.email,
        username: user.username,
      };

      return {
        access_token: this.jwtService.sign(newPayload),
      };
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  private generateRefreshToken(userId: string): string {
    return this.jwtService.sign(
      { sub: userId, type: 'refresh' },
      { secret: this.refreshSecret, expiresIn: this.refreshExpiration as any },
    );
  }
}
