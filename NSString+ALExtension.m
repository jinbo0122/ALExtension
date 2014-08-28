//
//  NSString+Category.m
//  Pandora
//
//  Created by Albert Lee on 12/25/13.
//  Copyright (c) 2013 Albert Lee. All rights reserved.
//

#import "NSString+ALExtension.h"
@implementation NSString (ALExtension)
+ (NSString*)currentTimeString{
  [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterFullStyle];
  [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
  return [NSString stringWithFormat:@"?%@",[dateFormatter stringFromDate:[NSDate date]]];
}

+ (NSString*)timeString:(NSTimeInterval)unixTime format:(MHPrettyDateFormat)format{
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixTime];
  
  NSString *timeString = [MHPrettyDate prettyDateFromDate:date
                                               withFormat:format];
  if (timeString.length>0 && [timeString characterAtIndex:0] == '-') {
    return [timeString substringFromIndex:1];
  }
  
  return timeString;
}
- (NSString *)trimWhitespace
{
  NSMutableString *str = [self mutableCopy];
  CFStringTrimWhitespace((CFMutableStringRef)str);
  return str;
}
#pragma mark String MD5 Encoding & Decoding
+ (NSString *)stringByMD5Encoding:(NSString*)inputString{
  const char *cStr = [inputString UTF8String];
  unsigned char result[16];
  CC_MD5(cStr, (CGFloat)strlen(cStr), result); // This is the md5 call
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3],
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]
          ];
}
#pragma mark URL String Encoding & Decoding
+ (NSString *)stringByDecodingURLFormat:(NSString*)inputString
{
  CFStringRef decodedCFString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                        (__bridge CFStringRef)inputString,
                                                                                        CFSTR(""),
                                                                                        kCFStringEncodingUTF8);
  if (decodedCFString == nil) {
    return inputString;
  }
  // We need to replace "+" with " " because the CF method above doesn't do it
  NSString *decodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) decodedCFString];
  return (!decodedString) ? @"" : [decodedString stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}
+ (NSString*)stringByEncodingURLFormat:(NSString*)inputString
{
  if ([inputString length]==0) {
    return @"";
  }
  NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                           (CFStringRef)inputString,
                                                                                           NULL,
                                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                           kCFStringEncodingUTF8));
  return result;
}

- (NSNumber *)numberValue{
  NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
  [f setNumberStyle:NSNumberFormatterDecimalStyle];
  return [f numberFromString:self];
}

- (NSData *)UTF8Data
{
  return [self dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark Cache Path Direction
+ (NSString *)pathByCacheDirection:(NSString*)customCacheDirectionName{
  NSArray *cacheDirectoryArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *pathString = [cacheDirectoryArray objectAtIndex:0];
  NSString *customCacheDirection = [pathString stringByAppendingPathComponent:customCacheDirectionName];
  if (![[NSFileManager defaultManager] fileExistsAtPath:customCacheDirection])
  {
    [[NSFileManager defaultManager] createDirectoryAtPath:customCacheDirection
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
  }
  
  return customCacheDirection;
}

+ (BOOL)stringContainsEmoji:(NSString *)string {
  __block BOOL returnValue = NO;
  [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
   ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
     
     const unichar hs = [substring characterAtIndex:0];
     // surrogate pair
     if (0xd800 <= hs && hs <= 0xdbff) {
       if (substring.length > 1) {
         const unichar ls = [substring characterAtIndex:1];
         const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
         if (0x1d000 <= uc && uc <= 0x1f77f) {
           returnValue = YES;
         }
       }
     } else if (substring.length > 1) {
       const unichar ls = [substring characterAtIndex:1];
       if (ls == 0x20e3) {
         returnValue = YES;
       }
       
     } else {
       // non surrogate
       if (0x2100 <= hs && hs <= 0x27ff) {
         returnValue = YES;
       } else if (0x2B05 <= hs && hs <= 0x2b07) {
         returnValue = YES;
       } else if (0x2934 <= hs && hs <= 0x2935) {
         returnValue = YES;
       } else if (0x3297 <= hs && hs <= 0x3299) {
         returnValue = YES;
       } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
         returnValue = YES;
       }
     }
   }];
  
  return returnValue;
}

#pragma mark Traditional Chinese Character
- (BOOL)containsTraditionalChinese{
//  for (NSInteger i=0;i<[self length];i++) {
//
//  }
  
  return NO;
}


#pragma mark Base64 Related

+ (NSString *)stringWithBase64EncodedString:(NSString *)string
{
  NSData *data = [NSData dataWithBase64EncodedString:string];
  if (data)
  {
    return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
  }
  return nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
  NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  return [data base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)base64EncodedString
{
  NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  return [data base64EncodedString];
}

- (NSString *)base64DecodedString
{
  return [NSString stringWithBase64EncodedString:self];
}

- (NSData *)base64DecodedData
{
  return [NSData dataWithBase64EncodedString:self];
}

@end
