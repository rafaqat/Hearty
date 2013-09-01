//
//  SMXAppDelegate.m
//  Hearty
//
//  Created by Simon Maddox on 31/08/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import "SMXAppDelegate.h"
#import "SMXHeartRateMonitor.h"

@interface SMXAppDelegate ()

@property (nonatomic, strong) SMXHeartRateMonitor *heartRateMonitor;

@end

@implementation SMXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[SMXHeartRateMonitor sharedInstance] attach];
    });
    
    return YES;
}

@end
