//
//  SSlackSecKey.h
//  libSSlack
//
//  Created by Rolandas Razma on 24/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

@import Foundation;
@import Security;


@interface SSlackSecKey : NSObject

@property (nonatomic, readonly) SecKeyRef key;
@property (nonatomic, readonly) SecExternalFormat format;
@property (nonatomic, readonly) SecExternalItemType itemType;

+ (instancetype)secKeyWithKey:(NSString *)key;

@end
