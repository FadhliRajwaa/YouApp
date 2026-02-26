import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(configService: ConfigService) {
    super({
      jwtFromRequest: (req: Request) => {
        // Support both x-access-token header and Authorization: Bearer
        const xToken = req.headers['x-access-token'] as string;
        if (xToken) return xToken;
        return ExtractJwt.fromAuthHeaderAsBearerToken()(req);
      },
      ignoreExpiration: false,
      secretOrKey: configService.getOrThrow<string>('JWT_SECRET'),
    });
  }

  async validate(payload: { sub?: string; id?: string; email: string; username: string }) {
    const userId = payload.sub || payload.id;
    if (!userId) {
      throw new UnauthorizedException();
    }
    return { userId, email: payload.email, username: payload.username };
  }
}
