import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
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
      create: jest.fn(),
    };

    mockJwtService = {
      sign: jest.fn().mockReturnValue('mock-token'),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: getModelToken(User.name), useValue: mockUserModel },
        { provide: JwtService, useValue: mockJwtService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  describe('register', () => {
    it('should register a new user successfully', async () => {
      mockUserModel.findOne.mockResolvedValue(null);
      mockUserModel.create.mockResolvedValue({ email: 'test@test.com' });

      const result = await service.register({
        email: 'test@test.com',
        username: 'testuser',
        password: 'password123',
      });

      expect(result.message).toBe('User has been created successfully');
      expect(mockUserModel.create).toHaveBeenCalled();
    });

    it('should throw ConflictException if user exists', async () => {
      mockUserModel.findOne.mockResolvedValue({ email: 'test@test.com' });

      await expect(
        service.register({
          email: 'test@test.com',
          username: 'testuser',
          password: 'password123',
        }),
      ).rejects.toThrow(ConflictException);
    });
  });

  describe('login', () => {
    it('should login successfully with valid credentials', async () => {
      const hashedPassword = await bcrypt.hash('password123', 10);
      mockUserModel.findOne.mockResolvedValue({
        _id: { toString: () => 'user-id' },
        email: 'test@test.com',
        username: 'testuser',
        password: hashedPassword,
      });

      const result = await service.login({
        email: 'test@test.com',
        username: 'testuser',
        password: 'password123',
      });

      expect(result.access_token).toBe('mock-token');
    });

    it('should throw UnauthorizedException with invalid credentials', async () => {
      mockUserModel.findOne.mockResolvedValue(null);

      await expect(
        service.login({
          email: 'wrong@test.com',
          username: 'wrong',
          password: 'wrong',
        }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
