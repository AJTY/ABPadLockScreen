//
//  AJTYKeyPadViewController.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//



#import "AJTYKeyPadAbstractViewController.h"
/**
 The ABPadLockScreenViewController presents a full screen pin to the user.
 Classess simply need to register as a delegate and implement the ABPadLockScreenViewControllerDelegate Protocol to recieve callbacks
 When a pin has been enteres successfully, unsuccessfully or when the entry has been cancelled.

 You are responsible for storing the pin securely (use the keychain or some other form of secure storage, DO NOT STORE IN PLAINTEXT. If you need the user to set a pin, please use ABPadLockScreenSetupViewController
 */
@class AJTYKeyPadViewController;
@protocol AJTYKeyPadViewControllerDelegate;

@interface AJTYKeyPadViewController : AJTYKeyPadAbstractViewController

- (instancetype)initWithDelegate:(id<AJTYKeyPadViewControllerDelegate>)delegate complexPin:(BOOL)complexPin;

@property (nonatomic, weak, readonly) id<AJTYKeyPadViewControllerDelegate> lockScreenDelegate;
@property (nonatomic, assign, readonly) NSInteger totalAttempts;
@property (nonatomic, assign, readonly) NSInteger remainingAttempts;

- (void)setAllowedAttempts:(NSInteger)allowedAttempts;

- (void)setLockedOutText:(NSString *)title;
- (void)setPluralAttemptsLeftText:(NSString *)title;
- (void)setSingleAttemptLeftText:(NSString *)title;

- (void)lockViewAnimated:(BOOL)animated withMessage:(NSString *)message completion:(void (^)(BOOL))completion;
- (void)unlockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion;

@end

@protocol AJTYKeyPadViewControllerDelegate <AJTYKeyPadViewDelegate>
@required

/**
 Called when pin validation is needed
 */
- (BOOL)padLockScreenViewController:(AJTYKeyPadViewController *)padLockScreenViewController validatePin:(NSString*)pin;

/**
 Called when the unlock was completed successfully
 */
- (void)unlockWasSuccessfulForPadLockScreenViewController:(AJTYKeyPadViewController *)padLockScreenViewController;

/**
 Called when an unlock was unsuccessfully, providing the entry code and the attempt number
 */
- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(AJTYKeyPadViewController *)padLockScreenViewController;

/**
 Called when the user cancels the unlock
 */
- (void)unlockWasCancelledForPadLockScreenViewController:(AJTYKeyPadViewController *)padLockScreenViewController;

@optional
/**
 Called when the user has expired their attempts
 */
- (void)attemptsExpiredForPadLockScreenViewController:(AJTYKeyPadViewController *)padLockScreenViewController;

@end