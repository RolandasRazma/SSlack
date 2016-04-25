//
//  SSlackSec.m
//  libSSlack
//
//  Created by Rolandas Razma on 23/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//
//  based on:
//  https://github.com/nikyoudale/CocoaCryptoMac
//

#import "SSlackSec.h"
@import Security;


@implementation SSlackSec


#pragma mark - SSlackSec

+ (NSData *)executeTransform:(SecTransformRef)transform withInput:(NSData *)input error:(NSError **)errorPtr {
    
    CFErrorRef error = NULL;
    CFTypeRef output = NULL;
    SecTransformSetAttribute(transform,
                             kSecTransformInputAttributeName,
                             (__bridge CFDataRef)input,
                             &error);
    
    if ( error ) {
        if ( errorPtr ) {
            *errorPtr = (__bridge NSError *)error;
        }
        CFRelease(error);
    }
    
    // A comment from QCCRSASmallCryptorT.m of the CryptoCompatibility sample code
    // https://developer.apple.com/library/mac/samplecode/CryptoCompatibility/Listings/Operations_QCCRSASmallCryptorT_m.html
    //
    // For an RSA key the transform does PKCS#1 padding by default.  Weirdly, if we explicitly
    // set the padding to kSecPaddingPKCS1Key then the transform fails <rdar://problem/13661366>.
    // Thus, if the client has requested PKCS#1, we leave paddingStr set to NULL, which prevents
    // us explicitly setting the padding to anything, which avoids the error while giving us
    // PKCS#1 padding.
    //
    // SecTransformSetAttribute(transform, kSecPaddingKey, kSecPaddingPKCS1Key, &error);
    output = SecTransformExecute(transform, &error);
    
    if ( error ) {
        if (errorPtr) {
            *errorPtr = (__bridge NSError *)error;
        }
        CFRelease(error);
    }
    
    if (output == NULL) {
        return nil;
    }
    
    NSData *encrypted = [NSData dataWithData:(__bridge NSData *)output];
    CFRelease(output);
    
    return encrypted;
}


+ (NSData *)encryptData:(NSData *)data withKey:(SSlackSecKey *)key error:(NSError **)errorPtr {
    NSParameterAssert(data);
    NSParameterAssert(key);
    
    CFErrorRef error = NULL;
    NSData *outData = nil;
    SecTransformRef transform = SecEncryptTransformCreate(key.key, &error);
    
    if ( transform != NULL ) {
        outData = [self executeTransform:transform withInput:data error:errorPtr];
        CFRelease(transform);
    }
    
    if (error) {
        if (errorPtr) {
            *errorPtr = (__bridge NSError *)error;
        }
        CFRelease(error);
    }
    
    return outData;
}


+ (NSData *)decryptData:(NSData *)data withKey:(SSlackSecKey *)key error:(NSError **)errorPtr {
    NSParameterAssert(data);
    NSParameterAssert(key);

    CFErrorRef error = NULL;
    SecTransformRef transform = SecDecryptTransformCreate(key.key, &error);
    NSData *outData = nil;
    
    if ( transform != NULL ) {
        outData = [self executeTransform:transform withInput:data error:errorPtr];
        CFRelease(transform);
    }
    
    if (error) {
        if (errorPtr) {
            *errorPtr = (__bridge NSError *)error;
        }
        CFRelease(error);
    }
    
    return outData;
    
}


@end


@implementation SSlackSec (NSString)


#pragma mark - SSlackSec (NSString)

+ (NSString *)encryptString:(NSString *)string withKey:(SSlackSecKey *)key error:(NSError **)error {
    if ( !string ) string = @"";
    
    NSData *encryptedMessage = [self encryptData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                         withKey:key
                                           error:error];
    
    if ( encryptedMessage.length ) {
        return [encryptedMessage base64EncodedStringWithOptions:kNilOptions];
    } else {
        return nil;
    }
    
}


+ (NSString *)decryptString:(NSString *)string withKey:(SSlackSecKey *)key error:(NSError **)error {
    if ( !string ) return nil;
    
    NSData *decryptedMessage = [self decryptData: [[NSData alloc] initWithBase64EncodedString:string options:kNilOptions]
                                         withKey:key
                                           error: error];
    
    if ( decryptedMessage.length ) {
        return [[NSString alloc] initWithData:decryptedMessage encoding:NSUTF8StringEncoding];
    } else {
        return nil;
    }
    
}


@end