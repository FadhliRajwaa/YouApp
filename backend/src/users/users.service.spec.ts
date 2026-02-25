import { Test, TestingModule } from '@nestjs/testing';
import { getModelToken } from '@nestjs/mongoose';
import { NotFoundException } from '@nestjs/common';
import { UsersService } from './users.service';
import { User } from './schemas/user.schema';

describe('UsersService', () => {
  let service: UsersService;
  let mockUserModel: any;

  beforeEach(async () => {
    mockUserModel = {
      findById: jest.fn(),
      findByIdAndUpdate: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: getModelToken(User.name), useValue: mockUserModel },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe('getProfile', () => {
    it('should return user profile', async () => {
      const mockUser = {
        _id: 'user-id',
        email: 'test@test.com',
        username: 'testuser',
        name: 'Test User',
        horoscope: 'Leo',
        zodiac: 'Pig',
      };

      mockUserModel.findById.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser),
      });

      const result = await service.getProfile('user-id');
      expect(result).toEqual(mockUser);
    });

    it('should throw NotFoundException if user not found', async () => {
      mockUserModel.findById.mockReturnValue({
        select: jest.fn().mockResolvedValue(null),
      });

      await expect(service.getProfile('invalid-id')).rejects.toThrow(NotFoundException);
    });
  });

  describe('createProfile', () => {
    it('should create profile with horoscope and zodiac', async () => {
      const mockUser = {
        _id: 'user-id',
        name: 'John Doe',
        birthday: new Date('1995-08-17'),
        horoscope: 'Leo',
        zodiac: 'Pig',
        height: 175,
        weight: 70,
        interests: ['Music'],
      };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser),
      });

      const result = await service.createProfile('user-id', {
        name: 'John Doe',
        birthday: '1995-08-17',
        height: 175,
        weight: 70,
        interests: ['Music'],
      });

      expect(result.horoscope).toBe('Leo');
      expect(result.zodiac).toBe('Pig');
    });
  });

  describe('updateProfile', () => {
    it('should update profile and recalculate horoscope on birthday change', async () => {
      const mockUser = {
        _id: 'user-id',
        name: 'Updated',
        horoscope: 'Aries',
        zodiac: 'Pig',
      };

      mockUserModel.findByIdAndUpdate.mockReturnValue({
        select: jest.fn().mockResolvedValue(mockUser),
      });

      const result = await service.updateProfile('user-id', {
        name: 'Updated',
        birthday: '1995-03-25',
      });

      expect(result.name).toBe('Updated');
    });
  });
});
