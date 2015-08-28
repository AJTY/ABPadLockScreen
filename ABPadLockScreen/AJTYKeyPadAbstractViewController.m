//
//  AJTYKeyPadAbstractViewController.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYKeyPadAbstractViewController.h"
#import "AJTYKeyPadAbstractViewController.h"
#import "AJTYKeyPadView.h"

#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((AJTYKeyPadView *) [self view])

@interface AJTYKeyPadAbstractViewController ()

- (void)setUpButtonMapping;
- (void)buttonSelected:(UIButton *)sender;


@end

@implementation AJTYKeyPadAbstractViewController

#pragma mark -
#pragma mark - init methods
- (instancetype)init
{
    self = [super init];
    if (self) {
        _tapSoundEnabled = YES;
        _errorVibrateEnabled = YES;
        _complexPin = NO; //default to NO
    }
    return self;
}

- (id)initWithComplexPin:(BOOL)complexPin
{
    self = [self init];
    if (self)
    {
        _complexPin = complexPin;
    }
    return self;
}

#pragma mark - View Controller Lifecycele Methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect bounds = self.view.bounds;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (bounds.size.width > bounds.size.height) {
            CGFloat height = bounds.size.width;
            CGFloat width = bounds.size.height;
            bounds.size.height = height;
            bounds.size.width = width;
        }
    }

    self.view = [[AJTYKeyPadView alloc] initWithFrame:bounds complexPin:self.isComplexPin];
    [lockScreenView.buttonCall addTarget:self action:@selector(callStarted:) forControlEvents:UIControlEventTouchUpInside];

    [self setUpButtonMapping];
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIUserInterfaceIdiom interfaceIdiom = [[UIDevice currentDevice] userInterfaceIdiom];

    if (interfaceIdiom == UIUserInterfaceIdiomPad) return UIInterfaceOrientationMaskAll;
    if (interfaceIdiom == UIUserInterfaceIdiomPhone) return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;

    return UIInterfaceOrientationMaskAll;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if(lockScreenView.backgroundView != nil) {
        return UIStatusBarStyleLightContent;
    }

    UIColor * color = lockScreenView.backgroundColor;

    if(color == nil) {
        color = lockScreenView.backgroundColor = [UIColor blackColor];
    }

    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    CGFloat colorBrightness = (CGColorGetNumberOfComponents(color.CGColor) == 2 ?
                               componentColors[0] :
                               ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000);

    if (colorBrightness < 0.5) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Localisation Methods
- (void)setLockScreenTitle:(NSString *)title
{
    self.title = title;
}

- (void)setSubtitleText:(NSString *)text
{
    lockScreenView.detailLabel.text = text;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [lockScreenView setBackgroundView:backgroundView];

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark - Helper Methods
- (void)setUpButtonMapping
{
    for (UIButton *button in [lockScreenView buttonArray])
    {
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Button Methods
- (void)buttonSelected:(UIButton *)sender
{
    if (self.tapSoundEnabled)
        AudioServicesPlaySystemSound(1105);
}

- (void)callStarted:(UIButton *)sender
{
    if ([lockScreenView.prepareForRedirect boolValue]) {
        if ([self.delegate respondsToSelector:@selector(callStartedDelegateWithNumber:)]) {
            [self.delegate callStartedDelegateWithNumber:(NSString * __nonnull const)lockScreenView.digitsTextField.text];
        }
        return;
    }

    if (!(sender.layer.backgroundColor == [UIColor redColor].CGColor) ) {
        NSString * timeElapsed = [self timer:self.timer];
        if ([self.delegate respondsToSelector:@selector(callEndedDelegateWithTime:)]) {
            self.startDate = nil;
            [self.timer invalidate];
            self.timer = nil;
            [self.delegate callEndedDelegateWithTime:timeElapsed];
        }
    }else{
        self.startDate = [NSDate date];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(timer:) userInfo:nil repeats:YES];
        if ([self.delegate respondsToSelector:@selector(callStartedDelegateWithNumber:)]) {
            [self.delegate callStartedDelegateWithNumber:(NSString * __nonnull const)lockScreenView.digitsTextField.text];
        }
    }
}

#pragma mark Timer
- (NSString *)timer:(NSTimer *)timer
{
    NSInteger secondsSinceStart = (NSInteger)[[NSDate date] timeIntervalSinceDate:self.startDate];

    NSInteger seconds = secondsSinceStart % 60;
    NSInteger minutes = (secondsSinceStart / 60) % 60;
    NSInteger hours = secondsSinceStart / (60 * 60);
    NSString *result = nil;

    if (hours > 0) {
        result = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    }else{
        result = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    lockScreenView.detailLabel.text = result;

    return result;
}

@end