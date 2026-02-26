import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';
import { CreateProfileDto, UpdateProfileDto } from './dto/profile.dto';
import { getHoroscope, getZodiac } from '../common/utils/horoscope.util';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
  ) {}

  async createProfile(userId: string, dto: CreateProfileDto): Promise<UserDocument> {
    const birthday = new Date(dto.birthday);
    const horoscope = getHoroscope(birthday);
    const zodiac = getZodiac(birthday);

    const updateData = {
      name: dto.name,
      gender: dto.gender,
      birthday,
      horoscope,
      zodiac,
      height: dto.height,
      weight: dto.weight,
      interests: dto.interests,
      profileImage: dto.profileImage,
    };

    const user = await this.userModel.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, runValidators: true },
    ).select('-password');

    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async searchUsers(query: string, currentUserId: string): Promise<UserDocument[]> {
    return this.userModel
      .find({
        _id: { $ne: currentUserId },
        username: { $regex: query, $options: 'i' },
      })
      .select('username name profileImage')
      .limit(20)
      .exec();
  }

  async getProfile(userId: string): Promise<UserDocument> {
    const user = await this.userModel.findById(userId).select('-password');
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<UserDocument> {
    const updateData: Record<string, any> = {};

    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.gender !== undefined) updateData.gender = dto.gender;
    if (dto.height !== undefined) updateData.height = dto.height;
    if (dto.weight !== undefined) updateData.weight = dto.weight;
    if (dto.interests !== undefined) updateData.interests = dto.interests;
    if (dto.profileImage !== undefined) updateData.profileImage = dto.profileImage;

    if (dto.birthday !== undefined) {
      if (dto.birthday === null) {
        updateData.birthday = null;
        updateData.horoscope = null;
        updateData.zodiac = null;
      } else {
        const birthday = new Date(dto.birthday);
        updateData.birthday = birthday;
        updateData.horoscope = getHoroscope(birthday);
        updateData.zodiac = getZodiac(birthday);
      }
    }

    const user = await this.userModel.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, runValidators: true },
    ).select('-password');

    if (!user) throw new NotFoundException('User not found');
    return user;
  }
}
