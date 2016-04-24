//
//  WebView+RRAdditions.h
//  libSSlack
//
//  Created by Rolandas Razma on 21/04/2016.
//  Copyright © 2016 Rolandas Razma. All rights reserved.
//

@import Cocoa;
@import WebKit;


static NSString * const WebViewRRAdditionsDidFinishLoadForFrameNotification = @"WebViewRRAdditionsDidFinishLoadForFrameNotification";


@interface WebView (RRAdditions)

@property (nonatomic, readonly) NSString *documentReadyState;

@end
