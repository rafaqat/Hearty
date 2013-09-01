//
//  SMXHeartViewController.m
//  Hearty
//
//  Created by Simon Maddox on 31/08/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import "SMXHeartViewController.h"
#import "SMXHeartRateMonitor.h"

@interface SMXHeartViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation SMXHeartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self);
	SMXHeartRateMonitorUpdated updatedBlock = ^(NSInteger heartRate){
        @strongify(self);
        self.label.text = [NSString stringWithFormat:@"%d", heartRate];
        //NSLog(@"%d BPM", heartRate);
    };
    [[SMXHeartRateMonitor sharedInstance] addHeartRateUpdatedCallback:updatedBlock];
}

@end
