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

    const updateData: any = { ...dto, birthday, horoscope, zodiac };

    const user = await this.userModel.findByIdAndUpdate(
      userId,
      updateData,
      { new: true, runValidators: true },
    ).select('-password');

    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async getProfile(userId: string): Promise<UserDocument> {
    const user = await this.userModel.findById(userId).select('-password');
    if (!user) throw new NotFoundException('User not found');
    return user;
  }

  async updateProfile(userId: string, dto: UpdateProfileDto): Promise<UserDocument> {
    const updateData: any = { ...dto };

    if (dto.birthday) {
      const birthday = new Date(dto.birthday);
      updateData.birthday = birthday;
      updateData.horoscope = getHoroscope(birthday);
      updateData.zodiac = getZodiac(birthday);
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
