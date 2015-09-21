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

- (void)lockScreen;

@end

@implementation AJTYKeyPadViewController
#pragma mark - Init Methods
- (instancetype)initWithDelegate:(id<AJTYKeyPadViewControllerDelegate>)delegate complexPin:(BOOL)complexPin prepareForRedirect:(BOOL)redirect
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        _lockScreenDelegate = delegate;
        lockScreenView.prepareForRedirect = [NSNumber numberWithBool:redirect];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<AJTYKeyPadViewControllerDelegate>)delegate complexPin:(BOOL)complexPin
{
    self = [super initWithComplexPin:complexPin];
    if (self)
    {
        self.delegate = delegate;
        _lockScreenDelegate = delegate;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    lockScreenView.digitsTextField.text = @"";
    [lockScreenView showDeleteButton:NO animated:NO completion:nil];
}

#pragma mark - Localisation Methods
- (void)setLockedOutText:(NSString *)title
{
    _lockedOutString = title;
}

#pragma mark - Pin Lock Key Pad
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