//
//  SSlackSecKey.m
//  libSSlack
//
//  Created by Rolandas Razma on 24/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

#import "SSlackSecKey.h"


@interface SSlackSecKey ()

@property (nonatomic, assign) SecKeyRef key;
@property (nonatomic, assign) SecExternalFormat format;
@property (nonatomic, assign) SecExternalItemType itemType;

@end


@implementation SSlackSecKey


#pragma mark - NSObject

- (void)dealloc {
    CFRelease(_key);
}


#pragma mark - SSlackSecKey

+ (NSData *)PEMKeyFromString:(NSString *)pemKey {
    if ( !pemKey.length ) return nil;
    
    NSMutableString *stripped = [NSMutableString stringWithString:pemKey];
    
    NSRegularExpression *headerRegex = [NSRegularExpression regularExpressionWithPattern:@"-----BEGIN (RSA )?(PUBLIC|PRIVATE) KEY-----"
                                                                                 options:0
                                                                                   error:nil];
    [headerRegex replaceMatchesInString:stripped
                                options:0
                                  range:NSMakeRange(0, stripped.length)
                           withTemplate:@""];
    
    NSRegularExpression *footerRegex = [NSRegularExpression regularExpressionWithPattern:@"-----END (RSA )?(PUBLIC|PRIVATE) KEY-----"
                                                                                 options:0
                                                                                   error:nil];
    [footerRegex replaceMatchesInString:stripped
                                options:0
                                  range:NSMakeRange(0, stripped.length)
                           withTemplate:@""];

    NSRegularExpression *whitespacesRegex = [NSRegularExpression regularExpressionWithPattern:@"\\s*"
                                                                                      options:0
                                                                                        error:nil];
    [whitespacesRegex replaceMatchesInString:stripped
                                     options:0
                                       range:NSMakeRange(0, stripped.length)
                                withTemplate:@""];
    
    return [[NSData alloc] initWithBase64EncodedString:stripped options:kNilOptions];
}


+ (SecKeyRef)createSecKeyWithKey:(NSString *)key format:(inout SecExternalFormat *)format itemType:(inout SecExternalItemType *)itemType {

    CFDataRef keyData = (__bridge CFDataRef)[self PEMKeyFromString:key];
    
    if ( !keyData || !CFDataGetLength(keyData) ) {
        return NULL;
    }

    CFArrayRef keys = NULL;
    OSStatus status = SecItemImport(keyData, NULL, format, itemType, 0, NULL, NULL, &keys);
    
    if ( status != 0 ) {
        NSLog(@"%@", CFBridgingRelease(SecCopyErrorMessageString(status, NULL)));
        return NULL;
    }
    
    if ( keys == NULL ) {
        return NULL;
    } else if ( CFArrayGetCount(keys) != 1 ) {
        CFRelease(keys);
        return NULL;
    }
    
    SecKeyRef keyRef = (SecKeyRef)CFRetain(CFArrayGetValueAtIndex(keys, 0));
    CFRelease(keys);
    
    return keyRef;
}


+ (instancetype)secKeyWithKey:(NSString *)key {
    NSParameterAssert(key);

    SecExternalFormat format = kSecFormatUnknown;
    SecExternalItemType itemType = kSecItemTypeUnknown;
    
    SecKeyRef secKeyRef = [self createSecKeyWithKey:key format:&format itemType:&itemType];
    if ( secKeyRef == NULL ) {
        return nil;
    }
    
    NSAssert((format != kSecFormatUnknown && itemType != kSecItemTypeUnknown), @"This not supposed to happen");

    SSlackSecKey *secKey = [[self alloc] initWithKeyRef:secKeyRef format:format itemType:itemType];
    CFRelease(secKeyRef);
    
    return secKey;
}


- (instancetype)initWithKeyRef:(SecKeyRef)key format:(SecExternalFormat)format itemType:(SecExternalItemType)itemType {
    if ( (self = [self init]) ) {
        [self setKey: (SecKeyRef)CFRetain(key)];
        [self setFormat:format];
        [self setItemType:itemType];
    }
    return self;
}


@end
