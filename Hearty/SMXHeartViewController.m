//
//  SMXHeartViewController.m
//  Hearty
//
//  Created by Simon Maddox on 31/08/2013.
//  Copyright (c) 2013 Simon Maddox. All rights reserved.
//

#import "SMXHeartViewController.h"
#import "SMXHeartRateMonitor.h"
#import <iOS-blur/AMBlurView.h>

@interface SMXHeartViewController ()

@property (nonatomic, copy) SMXHeartRateMonitorUpdated updatedBlock;

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *heartView;
@property (weak, nonatomic) IBOutlet UILabel *bpmLabel;
@property (weak, nonatomic) IBOutlet AMBlurView *blurView;

@end

@implementation SMXHeartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    @weakify(self);
	self.updatedBlock = ^(NSInteger heartRate){
        @strongify(self);
        
        [self removeBlurView];
        self.label.text = [NSString stringWithFormat:@"%d", heartRate];
    };
    
    [[SMXHeartRateMonitor sharedInstance] addHeartRateUpdatedCallback:self.updatedBlock];
    
    [self.blurView removeFromSuperview];
    [self animateHeartBeat];
}

- (void) dealloc
{
    [[SMXHeartRateMonitor sharedInstance] removeHeartRateUpdatedCallback:self.updatedBlock];
    self.updatedBlock = nil;
}

- (void) animateHeartBeat
{
    // TODO: Animate this at the same rate as the user's heart
    @weakify(self);
    [UIView animateWithDuration:60.0 / 120.0
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1
                        options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                     animations:^{
                         
                         @strongify(self);
                         CGFloat scaleFactor = 0.9;
                         self.heartView.transform = CGAffineTransformScale(self.heartView.transform, scaleFactor, scaleFactor);
                         
                     } completion:^(BOOL finished) {

                     }];
}

- (void) removeBlurView
{
    if (self.blurView){
        
        @weakify(self);
        [UIView animateWithDuration:0.5 animations:^{
            @strongify(self);
            self.blurView.alpha = 0;
        } completion:^(BOOL finished) {
            @strongify(self);
            [self.blurView removeFromSuperview];
            self.blurView = nil;
        }];
    }
}

@end
