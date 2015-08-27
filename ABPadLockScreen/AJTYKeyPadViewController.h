//
//  AJTYKeyPadViewController.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//



#import "AJTYKeyPadAbstractViewController.h"

@class AJTYKeyPadViewController;
@protocol AJTYKeyPadViewControllerDelegate;

@interface AJTYKeyPadViewController : AJTYKeyPadAbstractViewController

- (instancetype)initWithDelegate:(id<AJTYKeyPadViewControllerDelegate>)delegate complexPin:(BOOL)complexPin;

@property (nonatomic, weak, readonly) id<AJTYKeyPadViewControllerDelegate> lockScreenDelegate;
@property (nonatomic, assign, readonly) NSInteger totalAttempts;
@property (nonatomic, assign, readonly) NSInteger remainingAttempts;


- (void)setLockedOutText:(NSString *)title;
- (void)lockViewAnimated:(BOOL)animated withMessage:(NSString *)message completion:(void (^)(BOOL))completion;
- (void)unlockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion;

@end

@protocol AJTYKeyPadViewControllerDelegate <AJTYKeyPadViewDelegate>
@required

- (void) callButtonTriggered;

@end