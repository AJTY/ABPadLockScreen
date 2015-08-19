//
//  AJTYKeyPadViewController.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYKeyPadViewController.h"
#import "AJTYKeyPadViewController.h"
#import "AJTYKeyPadView.h"
#import "ABPinSelectionView.h"
#import <AudioToolbox/AudioToolbox.h>

#define lockScreenView ((AJTYKeyPadView *) [self view])

@interface AJTYKeyPadViewController ()

@property (nonatomic, strong) NSString *lockedOutString;
@property (nonatomic, strong) NSString *pluralAttemptsLeftString;
@property (nonatomic, strong) NSString *singleAttemptLeftString;

- (void)lockScreen;

@end

@implementation AJTYKeyPadViewController
#pragma mark -
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<AJTYKeyPadViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
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
#pragma mark - Pin Selection
- (void)lockScreen
{
    [lockScreenView updateDetailLabelWithString:[NSString stringWithFormat:@"%@", self.lockedOutString] animated:YES completion:nil];
    [lockScreenView lockViewAnimated:YES completion:nil];
}

-(void)lockViewAnimated:(BOOL)animated withMessage:(NSString *)message completion:(void (^)(BOOL))completion
{
    [lockScreenView lockViewAnimated:animated withMessage:message completion:nil];
}

- (void)unlockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion{
    [lockScreenView unlockViewAnimated:animated completion:nil];
}

@end