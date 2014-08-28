//
//  NSString+Category.h
//  Pandora
//
//  Created by Albert Lee on 12/25/13.
//  Copyright (c) 2013 Albert Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "MHPrettyDate/MHPrettyDate.h"
@interface NSString (ALExtension)
+ (NSString *)currentTimeString;
+ (NSString*)timeString:(NSTimeInterval)unixTime format:(MHPrettyDateFormat)format;
+ (NSString *)stringByMD5Encoding:(NSString*)inputString;
+ (NSString *)stringByDecodingURLFormat:(NSString*)inputString;
+ (NSString *)stringByEncodingURLFormat:(NSString*)inputString;
+ (NSString *)pathByCacheDirection:(NSString*)customCacheDirectionName;
- (BOOL)containsTraditionalChinese;
- (NSString *)trimWhitespace;
- (NSNumber *)numberValue;
- (NSData *)UTF8Data;
+ (BOOL)stringContainsEmoji:(NSString *)string;

#pragma mark Base64 Related
+ (NSString*)stringWithBase64EncodedString:(NSString *)string;
- (NSString*)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString*)base64EncodedString;
- (NSString*)base64DecodedString;
- (NSData  *)base64DecodedData;
@end
