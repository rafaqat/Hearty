//
//  SMXHeartRateMonitor.h
//  Hearty
//
//  Created by Simon Maddox on 31/08/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SMXHeartRateMonitorUpdated)(NSInteger heartRate);

@interface SMXHeartRateMonitor : NSObject

+ (instancetype) sharedInstance;

- (void) attach;
- (void) detatch;

- (void) addHeartRateUpdatedCallback:(SMXHeartRateMonitorUpdated)callback;
- (void) removeHeartRateUpdatedCallback:(SMXHeartRateMonitorUpdated)callback;

@end
