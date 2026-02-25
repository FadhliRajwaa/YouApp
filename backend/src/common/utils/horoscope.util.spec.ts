import { getHoroscope, getZodiac } from './horoscope.util';

describe('Horoscope Utility', () => {
  describe('getHoroscope', () => {
    it('should return Aries for March 21', () => {
      expect(getHoroscope(new Date('1995-03-21'))).toBe('Aries');
    });

    it('should return Taurus for April 25', () => {
      expect(getHoroscope(new Date('1995-04-25'))).toBe('Taurus');
    });

    it('should return Gemini for June 10', () => {
      expect(getHoroscope(new Date('1995-06-10'))).toBe('Gemini');
    });

    it('should return Cancer for July 1', () => {
      expect(getHoroscope(new Date('1995-07-01'))).toBe('Cancer');
    });

    it('should return Leo for August 17', () => {
      expect(getHoroscope(new Date('1995-08-17'))).toBe('Leo');
    });

    it('should return Virgo for September 5', () => {
      expect(getHoroscope(new Date('1995-09-05'))).toBe('Virgo');
    });

    it('should return Libra for October 10', () => {
      expect(getHoroscope(new Date('1995-10-10'))).toBe('Libra');
    });

    it('should return Scorpius for November 5', () => {
      expect(getHoroscope(new Date('1995-11-05'))).toBe('Scorpius');
    });

    it('should return Sagittarius for December 1', () => {
      expect(getHoroscope(new Date('1995-12-01'))).toBe('Sagittarius');
    });

    it('should return Capricornus for January 5', () => {
      expect(getHoroscope(new Date('1995-01-05'))).toBe('Capricornus');
    });

    it('should return Aquarius for February 10', () => {
      expect(getHoroscope(new Date('1995-02-10'))).toBe('Aquarius');
    });

    it('should return Pisces for March 10', () => {
      expect(getHoroscope(new Date('1995-03-10'))).toBe('Pisces');
    });
  });

  describe('getZodiac', () => {
    it('should return Pig for 1995', () => {
      expect(getZodiac(new Date('1995-08-17'))).toBe('Pig');
    });

    it('should return Rat for 1996', () => {
      expect(getZodiac(new Date('1996-01-01'))).toBe('Rat');
    });

    it('should return Dragon for 2000', () => {
      expect(getZodiac(new Date('2000-06-15'))).toBe('Dragon');
    });

    it('should return Tiger for 1998', () => {
      expect(getZodiac(new Date('1998-03-20'))).toBe('Tiger');
    });

    it('should return Rabbit for 2023', () => {
      expect(getZodiac(new Date('2023-05-10'))).toBe('Rabbit');
    });
  });
});
