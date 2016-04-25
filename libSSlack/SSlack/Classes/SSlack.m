//
//  SSlack.m
//  SSlack
//
//  Created by Rolandas Razma on 20/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//
//  openssl genrsa -out private_sslack.pem 4096
//  openssl rsa -pubout -in private_sslack.pem -out public_key.pem
//

#import "SSlack.h"
#import "SSlackJS.h"
#import "WebView+RRAdditions.h"
#import "SSlackSec.h"


@interface SSlack ()

@property (nonatomic, copy) NSString *UUID;
@property (nonatomic, copy) NSString *JS;

@end


@implementation SSlack


#pragma mark - NSObject

+ (void)load {
    NSLog(@"SSlack Loaded");

    [SSlack sharedInstance];
}


- (id)init {
    if ( (self = [super init]) ) {
        [self setUUID: [@"SSlack" stringByAppendingString: [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]]];
        [self setJS: [[NSString stringWithUTF8String:(const char *)SSlack_js] stringByReplacingOccurrencesOfString:@"__SSlack__" withString:self.UUID]];

        _keyPairs = [NSMutableDictionary new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(webViewRRAdditionsDidFinishLoadForFrameNotification:)
                                                     name:WebViewRRAdditionsDidFinishLoadForFrameNotification
                                                   object:nil];
    }
    return self;
}


#pragma mark - SSlack

static NSString * const kSSlackKeyRemotePublicKey  = @"kSSlackKeyRemotePublicKey";
static NSString * const kSSlackKeyLocalPublicKey   = @"kSSlackKeyLocalPublicKey";
static NSString * const kSSlackKeyLocalPrivateKey  = @"kSSlackKeyLocalPrivateKey";
static NSMutableDictionary <NSString *, NSDictionary <NSString *, SSlackSecKey *> *> *_keyPairs;


+ (instancetype)sharedInstance {
    static SSlack *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SSlack alloc] init];
    });
    
    return sharedInstance;
}


- (void)webViewRRAdditionsDidFinishLoadForFrameNotification:(NSNotification *)notification {
    JSContext *javaScriptContext = [(WebFrame *)notification.userInfo[@"frame"] javaScriptContext];
    
    if ( javaScriptContext ) {
        [javaScriptContext setExceptionHandler:^(JSContext *context, JSValue *value) {
            NSLog(@"JS exception %@", value);
        }];
        
        javaScriptContext[self.UUID] = self;
        [javaScriptContext evaluateScript: self.JS];
    }
}


- (NSString *)userInputWithMessageText:(NSString *)messageText informativeText:(NSString *)informativeText {

    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:messageText];
    [alert setInformativeText:informativeText];
    
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 24)];
    [alert setAccessoryView:textField];
    
    NSModalResponse modalResponse = [alert runModal];
    
    if ( modalResponse == NSAlertFirstButtonReturn ) {
        return textField.stringValue;
    } else {
        return nil;
    }
    
}


#pragma mark - SSlackJSExport <JSExport>

- (void)log:(id)object {
    NSLog(@"%@", object);
}


- (NSDictionary *)requestKeysForUserWithUUID:(NSString *)userUUID {

    
    NSString *remotePublicKey = [self userInputWithMessageText:@"Remote User Public key" informativeText:@"Remote Users public key that will be used to encrypt messages"];
    
    if ( !remotePublicKey.length ) return nil;
    
    SSlackSecKey *remotePublicSecKey = [SSlackSecKey secKeyWithKey:remotePublicKey];
    
    if ( !remotePublicSecKey ) return nil;

    
    NSString *localPublicKey = [self userInputWithMessageText:@"Your Public key" informativeText:@"Your public key that will be used to encript local messages"];
    
    if ( !localPublicKey.length ) return nil;
    
    SSlackSecKey *localPublicSecKey = [SSlackSecKey secKeyWithKey:localPublicKey];
    
    if ( !localPublicSecKey ) return nil;
    
    
    NSString *localPrivateKey = [self userInputWithMessageText:@"Your Private key" informativeText:@"Your private key that will be used to decrypt messages"];
    
    if ( !localPrivateKey.length ) return nil;
    
    SSlackSecKey *localPrivateSecKey = [SSlackSecKey secKeyWithKey:localPrivateKey];
    
    if ( !localPrivateSecKey ) return nil;
    
    
    _keyPairs[userUUID] = @{
        kSSlackKeyRemotePublicKey: remotePublicSecKey,
         kSSlackKeyLocalPublicKey: localPublicSecKey,
        kSSlackKeyLocalPrivateKey: localPrivateSecKey
    };
    
    return _keyPairs[userUUID];
}


- (NSString *)encryptMessage:(NSString *)message toUserUUID:(NSString *)userUUID inChannel:(NSString *)channelUUID isOwn:(BOOL)isOwn {

    if ( ![self isEncryptingChannelWithUUID:channelUUID] ) {
        [self requestKeysForUserWithUUID:channelUUID];
    }
    
    SSlackSecKey *publicKey = _keyPairs[channelUUID][isOwn?kSSlackKeyLocalPublicKey:kSSlackKeyRemotePublicKey];
    if ( !publicKey ) {
        return nil;
    }
    
    NSError *error;
    message = [SSlackSec encryptString:message
                               withKey:publicKey
                                 error:&error];

    if ( error ) {
        NSLog(@"encryptMessage:toUserUUID: failed with error: %li - %@", (long)error.code, error.localizedDescription);
    }
    
    return message;
}


- (NSString *)decryptMessage:(NSString *)message inChannel:(NSString *)channelUUID {
    if ( !message.length ) return message;
    
    if ( ![self isEncryptingChannelWithUUID:channelUUID] ) {
        [self requestKeysForUserWithUUID:channelUUID];
    }
    
    SSlackSecKey *privateKey = _keyPairs[channelUUID][kSSlackKeyLocalPrivateKey];
    if ( !privateKey ) {
        return nil;
    }

    NSError *error;
    message = [SSlackSec decryptString:message
                               withKey:privateKey
                                 error:&error];

    if ( error ) {
        NSLog(@"decryptMessage:fromUserUUID: failed with error: %li - %@", (long)error.code, error.localizedDescription);
    }

    return message;
}


- (BOOL)isEncryptingChannelWithUUID:(NSString *)channelUUID {
    if ( !channelUUID.length ) return NO;
    
    return (_keyPairs[channelUUID] != nil);
}


- (BOOL)startEncryptingChannelWithUUID:(NSString *)channelUUID {
    if ( !channelUUID.length ) return NO;
    
    [self requestKeysForUserWithUUID:channelUUID];
    
    return [self isEncryptingChannelWithUUID:channelUUID];
}


- (BOOL)stopEncryptingChannelWithUUID:(NSString *)channelUUID {
    if ( !channelUUID.length ) return NO;
    
    [_keyPairs removeObjectForKey:channelUUID];
    
    return YES;
}


@end