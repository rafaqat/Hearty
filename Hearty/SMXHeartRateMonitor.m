//
//  SMXHeartRateMonitor.m
//  Hearty
//
//  Created by Simon Maddox on 31/08/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import "SMXHeartRateMonitor.h"
#import <WFConnector/WFConnector.h>

@interface SMXHeartRateMonitor () <WFHardwareConnectorDelegate, WFSensorConnectionDelegate>

@property (nonatomic, strong) WFHeartrateConnection *heartRateConnector;
@property (nonatomic, strong) NSTimer *hrmTimer;

@property (nonatomic, strong) NSMutableSet *callbacks;

@end

@implementation SMXHeartRateMonitor

+ (instancetype) sharedInstance
{
    static dispatch_once_t onceToken;
    static SMXHeartRateMonitor *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SMXHeartRateMonitor alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init
{
    if (self = [super init]){
        self.callbacks = [NSMutableSet set];
    }
    return self;
}

- (void) attach
{
    [[WFHardwareConnector sharedConnector] enableBTLE:YES];
    [[WFHardwareConnector sharedConnector] setDelegate:self];
}

- (void) detatch
{
    [self.callbacks removeAllObjects];
    [self.heartRateConnector disconnect];
    [[WFHardwareConnector sharedConnector] setDelegate:nil];
    [[WFHardwareConnector sharedConnector] enableBTLE:NO];
}

- (void) addHeartRateUpdatedCallback:(SMXHeartRateMonitorUpdated)callback
{
    [self.callbacks addObject:callback];
}

- (void) removeHeartRateUpdatedCallback:(SMXHeartRateMonitorUpdated)callback
{
    [self.callbacks removeObject:callback];
}

- (void) updateHeartRate
{
    NSString *heartRateString = [[self.heartRateConnector getHeartrateData] formattedHeartrate:NO];
    if (heartRateString){
        NSInteger heartRate = [heartRateString integerValue];
        [self.callbacks enumerateObjectsUsingBlock:^(SMXHeartRateMonitorUpdated callback, BOOL *stop) {
            callback(heartRate);
        }];
    }
}

#pragma mark - WFHardwareConnectorDelegate methods

- (void)hardwareConnector:(WFHardwareConnector*)hwConnector connectedSensor:(WFSensorConnection*)connectionInfo
{
    NSLog(@"Connected Device: %@", [connectionInfo deviceUUIDString]);
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.hrmTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                         target:self
                                                       selector:@selector(updateHeartRate)
                                                       userInfo:nil
                                                        repeats:YES];
    });
}

- (void)hardwareConnector:(WFHardwareConnector*)hwConnector disconnectedSensor:(WFSensorConnection*)connectionInfo
{
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.hrmTimer invalidate];
    });
    NSLog(@"Disconnected Device: %@", [connectionInfo deviceUUIDString]);
}

- (void)hardwareConnector:(WFHardwareConnector*)hwConnector stateChanged:(WFHardwareConnectorState_t)currentState
{
    if (currentState == WF_HWCONN_STATE_BT40_ENABLED){
        
        NSLog(@"BTLE enabled");
        
        WFConnectionParams *params = [[WFConnectionParams alloc] init];
        params.sensorType = WF_SENSORTYPE_HEARTRATE;
        
        self.heartRateConnector = (WFHeartrateConnection *)[[WFHardwareConnector sharedConnector] requestSensorConnection:params];
        self.heartRateConnector.delegate = self;
    } else {
        NSLog(@"Other State: %c", currentState);
    }
}

#pragma mark - WFSensorConnectionDelegate methods

- (void)connectionDidTimeout:(WFSensorConnection*)connectionInfo
{
    NSLog(@"Sensor connection timed out");
}

@end
