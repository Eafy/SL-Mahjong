//
//  NSDate+Categary.m
//  JimiLive
//
//  Created by lizhijian on 16/4/1.
//  Copyright © 2016年 Concox. All rights reserved.
//

#import "NSString+DES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (DES)

- (NSString *)cryptDESStringWithKey:(NSString *)key
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES, kCCOptionPKCS7Padding | kCCOptionECBMode, [key UTF8String], kCCBlockSizeDES, NULL, [data bytes], data.length, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [self stringFromBytes:buffer length:numBytesEncrypted];
    }
    free(buffer);
    
    return @"";
}

- (NSString *)stringFromBytes:(unsigned char *)bytes length:(NSUInteger)length
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    return [NSString stringWithString:mutableString];
}

@end
