//
//  WebView+RRAdditions.m
//  libSSlack
//
//  Created by Rolandas Razma on 21/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

#import "WebView+RRAdditions.h"
#import <objc/runtime.h>


void SwizzleMethod(Class c, SEL orig, SEL new) {
    
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    
    if ( class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)) )
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}


@implementation WebView (RRAdditions)


#pragma mark - NSObject

+ (void)load {
    SwizzleMethod([self class], @selector(setFrameLoadDelegate:), @selector(_rr_r_setFrameLoadDelegate:));
    SwizzleMethod([self class], @selector(frameLoadDelegate), @selector(_rr_r_frameLoadDelegate));
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || [self.realFrameLoadDelegate respondsToSelector:aSelector];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    
    if ( !signature && [self.realFrameLoadDelegate respondsToSelector:selector] ) {
        return [(NSObject *)self.realFrameLoadDelegate methodSignatureForSelector:selector];
    }
    
    return signature;
}


- (void)forwardInvocation:(NSInvocation*)invocation {
    if ( [self.realFrameLoadDelegate respondsToSelector:[invocation selector]] ) {
        [invocation invokeWithTarget:self.realFrameLoadDelegate];
    }
}


#pragma mark - WebView

- (void)_rr_r_setFrameLoadDelegate:(id <WebFrameLoadDelegate>)frameLoadDelegate {
    [self setRealFrameLoadDelegate:frameLoadDelegate];
    
    if ( frameLoadDelegate ) {
        [self _rr_r_setFrameLoadDelegate:(id <WebFrameLoadDelegate>)self];
    } else {
        [self _rr_r_setFrameLoadDelegate:nil];
    }
}


- (id <WebFrameLoadDelegate>)_rr_r_frameLoadDelegate {
    return [self realFrameLoadDelegate];
}


#pragma mark - WebView (RRAdditions)

- (id <WebFrameLoadDelegate>)realFrameLoadDelegate {
    return objc_getAssociatedObject(self, @selector(realFrameLoadDelegate));
}


- (void)setRealFrameLoadDelegate:(id <WebFrameLoadDelegate>)frameLoadDelegate {
    objc_setAssociatedObject(self, @selector(realFrameLoadDelegate), frameLoadDelegate, OBJC_ASSOCIATION_ASSIGN);
}


- (NSString *)documentReadyState {
    return [self stringByEvaluatingJavaScriptFromString:@"document.readyState"];
}


#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)webView didFinishLoadForFrame:(WebFrame *)frame {

    [[NSNotificationCenter defaultCenter] postNotificationName:WebViewRRAdditionsDidFinishLoadForFrameNotification
                                                        object:self
                                                      userInfo:@{ @"frame": frame }];
    
    if ( [self.realFrameLoadDelegate respondsToSelector:@selector(webView:didFinishLoadForFrame:)] ) {
        [self.realFrameLoadDelegate webView:webView didFinishLoadForFrame:frame];
    }
    
}


@end