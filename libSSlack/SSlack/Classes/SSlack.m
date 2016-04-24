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
//  openssl genrsa -out private_sslack.pem 4096 && openssl rsa -pubout -in private_sslack.pem -out public_key.pem
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

static NSString * const kSSlackKeyPairPublicKey  = @"kSSlackKeyPairPublicKey";
static NSString * const kSSlackKeyPairPrivateKey = @"kSSlackKeyPairPrivateKey";
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
    NSLog(@"requestKeysForUserWithUUID: %@", userUUID);
    
    NSString *publicKey = [self userInputWithMessageText:@"Public key" informativeText:@"Users public key that will be used to encrypt messages"];
    
    if ( !publicKey.length ) return nil;
    
    SSlackSecKey *publicSecKey = [SSlackSecKey secKeyWithKey:publicKey];
    
    if ( !publicSecKey ) return nil;

    
    NSString *privateKey = [self userInputWithMessageText:@"Private key" informativeText:@"Your private key that will be used to decrypt messages"];
    
    if ( !privateKey.length ) return nil;
    
    SSlackSecKey *privateSecKey = [SSlackSecKey secKeyWithKey:privateKey];
    
    if ( !privateSecKey ) return nil;
    
    _keyPairs[userUUID] = @{
         kSSlackKeyPairPublicKey: publicSecKey,
        kSSlackKeyPairPrivateKey: privateSecKey
    };
    
    return _keyPairs[userUUID];
}


- (NSString *)encryptMessage:(NSString *)message toUserUUID:(NSString *)userUUID {
 
    if ( ![self isEncryptingChannelWithUUID:userUUID] ) {
        [self requestKeysForUserWithUUID:userUUID];
    }
    
    SSlackSecKey *publicKey = _keyPairs[userUUID][kSSlackKeyPairPublicKey];
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


- (NSString *)decryptMessage:(NSString *)message fromUserUUID:(NSString *)userUUID {
    if ( !message.length ) return message;

    if ( ![self isEncryptingChannelWithUUID:userUUID] ) {
        [self requestKeysForUserWithUUID:userUUID];
    }
    
    SSlackSecKey *privateKey = _keyPairs[userUUID][kSSlackKeyPairPrivateKey];
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