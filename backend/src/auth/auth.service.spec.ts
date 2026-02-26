import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { ConflictException, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';
import { User } from '../users/schemas/user.schema';

describe('AuthService', () => {
  let service: AuthService;
  let mockUserModel: any;
  let mockJwtService: any;

  beforeEach(async () => {
    mockUserModel = {
      findOne: jest.fn(),
      findById: jest.fn(),
      create: jest.fn(),
    };

    mockJwtService = {
      sign: jest.fn().mockReturnValue('mock-token'),
      verify: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getModelToken(User.name), useValue: mockUserModel },
        { provide: JwtService, useValue: mockJwtService },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultVal?: string) => {
              const config: Record<string, string> = {
                JWT_SECRET: 'test-secret',
                JWT_REFRESH_SECRET: 'test-refresh-secret',
                JWT_REFRESH_EXPIRATION: '7d',
              };
              return config[key] || defaultVal;
            }),
            getOrThrow: jest.fn().mockReturnValue('test-secret'),
          },
        },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      mockUserModel.create.mockResolvedValue({ email: 'test@test.com' });

      const result = await service.register({
        email: 'test@test.com',
        username: 'testuser',
        password: 'password123',
      });

      expect(result.message).toBe('User has been created successfully');
      expect(mockUserModel.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@test.com',
          username: 'testuser',
        }),
      );
    });

    it('should throw ConflictException on duplicate email/username (MongoDB error 11000)', async () => {
      mockUserModel.create.mockRejectedValue({ code: 11000 });

      await expect(
        service.register({
          email: 'test@test.com',
          username: 'testuser',
          password: 'password123',
        }),
      ).rejects.toThrow(ConflictException);
    });

    it('should normalize email and username to lowercase', async () => {
      mockUserModel.create.mockResolvedValue({ email: 'test@test.com' });

      await service.register({
        email: 'Test@Test.COM',
        username: 'TestUser',
        password: 'password123',
      });

      expect(mockUserModel.create).toHaveBeenCalledWith(
        expect.objectContaining({
          email: 'test@test.com',
          username: 'testuser',
        }),
      );
    });
  });

  describe('login', () => {
    it('should login successfully and return access_token, refresh_token, and userId', async () => {
      const hashedPassword = await bcrypt.hash('password123', 10);
      mockUserModel.findOne.mockResolvedValue({
        _id: { toString: () => 'user-id' },
        email: 'test@test.com',
        username: 'testuser',
        password: hashedPassword,
      });

      const result = await service.login({
        usernameOrEmail: 'test@test.com',
        password: 'password123',
      });

      expect(result.access_token).toBe('mock-token');
      expect(result.refresh_token).toBe('mock-token');
      expect(result.userId).toBe('user-id');
      expect(mockJwtService.sign).toHaveBeenCalledTimes(2);
    });

    it('should throw UnauthorizedException when user not found', async () => {
      mockUserModel.findOne.mockResolvedValue(null);

      await expect(
        service.login({
          usernameOrEmail: 'wrong@test.com',
          password: 'wrong',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException when password is wrong', async () => {
      const hashedPassword = await bcrypt.hash('correctpassword', 10);
      mockUserModel.findOne.mockResolvedValue({
        _id: { toString: () => 'user-id' },
        email: 'test@test.com',
        username: 'testuser',
        password: hashedPassword,
      });

      await expect(
        service.login({
          usernameOrEmail: 'test@test.com',
          password: 'wrongpassword',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });

  describe('refresh', () => {
    it('should return new access_token for valid refresh token', async () => {
      mockJwtService.verify.mockReturnValue({
        sub: 'user-id',
        type: 'refresh',
      });
      mockUserModel.findById.mockReturnValue({
        select: jest.fn().mockResolvedValue({
          _id: { toString: () => 'user-id' },
          email: 'test@test.com',
          username: 'testuser',
        }),
      });

      const result = await service.refresh('valid-refresh-token');

      expect(result.access_token).toBe('mock-token');
      expect(mockJwtService.verify).toHaveBeenCalledWith('valid-refresh-token', {
        secret: 'test-refresh-secret',
      });
    });

    it('should throw UnauthorizedException for invalid token type', async () => {
      mockJwtService.verify.mockReturnValue({
        sub: 'user-id',
        type: 'access',
      });

      await expect(service.refresh('access-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException when user no longer exists', async () => {
      mockJwtService.verify.mockReturnValue({
        sub: 'deleted-user-id',
        type: 'refresh',
      });
      mockUserModel.findById.mockReturnValue({
        select: jest.fn().mockResolvedValue(null),
      });

      await expect(service.refresh('valid-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException for expired refresh token', async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error('jwt expired');
      });

      await expect(service.refresh('expired-token')).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
