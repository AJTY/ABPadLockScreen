//
//  AJTYKeyPadViewController.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYKeyPadViewController.h"
#import "ABPadLockScreenViewController.h"
#import "ABPadLockScreenView.h"
#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((ABPadLockScreenView *) [self view])

@interface AJTYKeyPadViewController ()

@property (nonatomic, strong) NSString *lockedOutString;
@property (nonatomic, strong) NSString *pluralAttemptsLeftString;
@property (nonatomic, strong) NSString *singleAttemptLeftString;

- (BOOL)isPinValid:(NSString *)pin;

- (void)unlockScreen;
- (void)processFailure;
- (void)lockScreen;

@end

@implementation AJTYKeyPadViewController
#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<ABPadLockScreenViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        _lockScreenDelegate = delegate;
        _remainingAttempts = -1;

        _lockedOutString = NSLocalizedString(@"You have been locked out.", @"");
        _pluralAttemptsLeftString = NSLocalizedString(@"attempts left", @"");
        _singleAttemptLeftString = NSLocalizedString(@"attempt left", @"");
    }
    return self;
}

#pragma mark -
#pragma mark - Attempts
- (void)setAllowedAttempts:(NSInteger)allowedAttempts
{
    _totalAttempts = 0;
    _remainingAttempts = allowedAttempts;
}

#pragma mark -
#pragma mark - Localisation Methods
- (void)setLockedOutText:(NSString *)title
{
    _lockedOutString = title;
}

- (void)setPluralAttemptsLeftText:(NSString *)title
{
    _pluralAttemptsLeftString = title;
}

- (void)setSingleAttemptLeftText:(NSString *)title
{
    _singleAttemptLeftString = title;
}

#pragma mark -
#pragma mark - Pin Processing
- (void)processPin
{
    if ([self isPinValid:self.currentPin])
    {
        [self unlockScreen];
    }
    else
    {
        [self processFailure];
    }
}

- (void)unlockScreen
{
    if ([self.lockScreenDelegate respondsToSelector:@selector(unlockWasSuccessfulForPadLockScreenViewController:)])
    {
        [self.lockScreenDelegate unlockWasSuccessfulForPadLockScreenViewController:self];
    }
}

- (void)processFailure
{
    _remainingAttempts --;
    _totalAttempts ++;
    [lockScreenView resetAnimated:YES];
    [lockScreenView animateFailureNotification];

    if (self.remainingAttempts > 1)
    {
        [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%ld %@", (long)self.remainingAttempts, self.pluralAttemptsLeftString]
                                           animated:YES completion:nil];
    }
    else if (self.remainingAttempts == 1)
    {
        [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%ld %@", (long)self.remainingAttempts, self.singleAttemptLeftString]
                                           animated:YES completion:nil];
    }
    else if (self.remainingAttempts == 0)
    {
        [self lockScreen];
    }

    if ([self.lockScreenDelegate respondsToSelector:@selector(unlockWasUnsuccessful:afterAttemptNumber:padLockScreenViewController:)])
    {
        [self.lockScreenDelegate unlockWasUnsuccessful:self.currentPin afterAttemptNumber:self.totalAttempts padLockScreenViewController:self];
    }
    self.currentPin = @"";

    if (self.errorVibrateEnabled)
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (BOOL)isPinValid:(NSString *)pin
{
    if ([self.lockScreenDelegate respondsToSelector:@selector(padLockScreenViewController:validatePin:)])
    {
        return [self.lockScreenDelegate padLockScreenViewController:self validatePin:pin];
    }
    return NO;
}

#pragma mark -
#pragma mark - Pin Selection
- (void)lockScreen
{
    [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%@", self.lockedOutString] animated:YES completion:nil];
    [lockScreenView lockViewAnimated:YES completion:nil];

    if ([self.lockScreenDelegate respondsToSelector:@selector(attemptsExpiredForPadLockScreenViewController:)])
    {
        [self.lockScreenDelegate attemptsExpiredForPadLockScreenViewController:self];
    }
}

@end