//
//  SSlackSec.h
//  libSSlack
//
//  Created by Rolandas Razma on 23/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

@import Foundation;
#import "SSlackSecKey.h"


@interface SSlackSec : NSObject

+ (NSData *)encryptData:(NSData *)data withKey:(SSlackSecKey *)key error:(NSError **)error;
+ (NSData *)decryptData:(NSData *)data withKey:(SSlackSecKey *)key error:(NSError **)error;

@end


@interface SSlackSec (NSString)

+ (NSString *)encryptString:(NSString *)string withKey:(SSlackSecKey *)key error:(NSError **)error;
+ (NSString *)decryptString:(NSString *)string withKey:(SSlackSecKey *)key error:(NSError **)error;

@end