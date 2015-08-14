//
//  AJTYKeyPadAbstractViewController.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYKeyPadAbstractViewController.h"

//#import "ABPadLockScreenAbstractViewController.h"
//#import "ABPadLockScreenView.h"
#import "AJTYKeyPadAbstractViewController.h"
#import "AJTYKeyPadView.h"

#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((AJTYKeyPadView *) [self view])

@interface AJTYKeyPadAbstractViewController ()

- (void)setUpButtonMapping;
- (void)buttonSelected:(UIButton *)sender;
- (void)cancelButtonSelected:(UIButton *)sender;
- (void)deleteButtonSelected:(UIButton *)sender;
- (void)okButtonSelected:(UIButton *)sender;

@end

@implementation AJTYKeyPadAbstractViewController

#pragma mark -
#pragma mark - init methods
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _tapSoundEnabled = NO;
        _errorVibrateEnabled = NO;
        _currentPin = @"";
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

#pragma mark -
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

    [self setUpButtonMapping];
    [lockScreenView.cancelButton addTarget:self action:@selector(cancelButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [lockScreenView.deleteButton addTarget:self action:@selector(deleteButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    [lockScreenView.okButton addTarget:self action:@selector(okButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
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
    if(lockScreenView.backgroundView != nil)
    {
        //Background view is shown - need light content status bar.
        return UIStatusBarStyleLightContent;
    }

    //Check background color if light or dark.
    UIColor* color = lockScreenView.backgroundColor;

    if(color == nil)
    {
        color = lockScreenView.backgroundColor = [UIColor blackColor];
    }

    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);

    //Determine brightness
    CGFloat colorBrightness = (CGColorGetNumberOfComponents(color.CGColor) == 2 ?
                               //Black and white color
                               componentColors[0] :
                               //RGB color
                               ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000);

    if (colorBrightness < 0.5)
    {
        return UIStatusBarStyleLightContent;
    }
    else
    {
        return UIStatusBarStyleDefault;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark - Localisation Methods
- (void)setLockScreenTitle:(NSString *)title
{
    self.title = title;
    lockScreenView.enterPasscodeLabel.text = title;
}

- (void)setSubtitleText:(NSString *)text
{
    lockScreenView.detailLabel.text = text;
}

- (void)setCancelButtonText:(NSString *)text
{
    [lockScreenView.cancelButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.cancelButton sizeToFit];
}

- (void)setDeleteButtonText:(NSString *)text
{
    [lockScreenView.deleteButton setTitle:text forState:UIControlStateNormal];
    [lockScreenView.deleteButton sizeToFit];
}

- (void)setEnterPasscodeLabelText:(NSString *)text
{
    lockScreenView.enterPasscodeLabel.text = text;
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    [lockScreenView setBackgroundView:backgroundView];

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark -
#pragma mark - Helper Methods
- (void)setUpButtonMapping
{
    for (UIButton *button in [lockScreenView buttonArray])
    {
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)cancelButtonDisabled:(BOOL)disabled
{
    lockScreenView.cancelButtonDisabled = disabled;
}

- (void)processPin
{
    //Subclass to provide concrete implementation
}

#pragma mark -
#pragma mark - Button Methods
- (void)newPinSelected:(NSInteger)pinNumber
{
    if (!self.isComplexPin && [self.currentPin length] >= SIMPLE_PIN_LENGTH)
    {
        return;
    }

    self.currentPin = [NSString stringWithFormat:@"%@%ld", self.currentPin, (long)pinNumber];

    if(self.isComplexPin)
    {
        [lockScreenView updatePinTextfieldWithLength:self.currentPin.length];
    }
    else
    {
        NSUInteger curSelected = [self.currentPin length] - 1;
        [lockScreenView.digitsArray[curSelected]  setSelected:YES animated:YES completion:nil];
    }

    if ([self.currentPin length] == 1)
    {
        [lockScreenView showDeleteButtonAnimated:YES completion:nil];

        if(self.complexPin)
        {
            [lockScreenView showOKButton:YES animated:YES completion:nil];
        }
    }
    else if (!self.isComplexPin && [self.currentPin length] == SIMPLE_PIN_LENGTH)
    {
        [lockScreenView.digitsArray.lastObject setSelected:YES animated:YES completion:nil];
        [self processPin];
    }
}

- (void)deleteFromPin
{
    if ([self.currentPin length] == 0)
    {
        return;
    }

    self.currentPin = [self.currentPin substringWithRange:NSMakeRange(0, [self.currentPin length] - 1)];

    if(self.isComplexPin)
    {
        [lockScreenView updatePinTextfieldWithLength:self.currentPin.length];
    }
    else
    {
        NSUInteger pinToDeselect = [self.currentPin length];
        [lockScreenView.digitsArray[pinToDeselect] setSelected:NO animated:YES completion:nil];
    }

    if ([self.currentPin length] == 0)
    {
        [lockScreenView showCancelButtonAnimated:YES completion:nil];
        [lockScreenView showOKButton:NO animated:YES completion:nil];
    }
}

- (void)buttonSelected:(UIButton *)sender
{
    NSInteger tag = sender.tag;
    if (self.tapSoundEnabled)
    {
        AudioServicesPlaySystemSound(1105);
    }
    [self newPinSelected:tag];
}

- (void)cancelButtonSelected:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(unlockWasCancelledForPadLockScreenViewController:)])
    {
        [self.delegate unlockWasCancelledForPadLockScreenViewController:self];
    }
}

- (void)deleteButtonSelected:(UIButton *)sender
{
    [self deleteFromPin];
}

- (void)okButtonSelected:(UIButton *)sender
{
    [self processPin];
}

@end