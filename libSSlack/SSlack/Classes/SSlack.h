//
//  SSlack.h
//  SSlack
//
//  Created by Rolandas Razma on 20/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

@import Foundation;
@import JavaScriptCore;


@protocol SSlackJSExport <JSExport>

- (void)log:(id)object;

JSExportAs(isEncrypting,    - (BOOL)isEncryptingChannelWithUUID:(NSString *)channelUUID);
JSExportAs(startEncrypting, - (BOOL)startEncryptingChannelWithUUID:(NSString *)channelUUID);
JSExportAs(stopEncrypting,  - (BOOL)stopEncryptingChannelWithUUID:(NSString *)channelUUID);
JSExportAs(encrypt,         - (NSString *)encryptMessage:(NSString *)message toUserUUID:(NSString *)userUUID inChannel:(NSString *)channelUUID isOwn:(BOOL)isOwn);
JSExportAs(decrypt,         - (NSString *)decryptMessage:(NSString *)message inChannel:(NSString *)channelUUID);

@end


@interface SSlack : NSObject <SSlackJSExport>

@end
