//
//  AJTYKeyPadAbstractViewController.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

@protocol ABPadLockScreenDelegate;
@class ABPadLockScreenView;

@interface AJTYKeyPadAbstractViewController : UIViewController
{
    ABPadLockScreenView* lockScreenView;
}

@property (nonatomic, strong) NSString *currentPin;
@property (nonatomic, weak) id<ABPadLockScreenDelegate> delegate;
@property (nonatomic, readonly, getter = isComplexPin) BOOL complexPin;
@property (nonatomic, assign) BOOL tapSoundEnabled; //No by Default
@property (nonatomic, assign) BOOL errorVibrateEnabled; //No by Default

- (id)initWithComplexPin:(BOOL)complexPin;

- (void)newPinSelected:(NSInteger)pinNumber;
- (void)deleteFromPin;

- (void)setLockScreenTitle:(NSString *)title;
- (void)setSubtitleText:(NSString *)text;
- (void)setCancelButtonText:(NSString *)text;
- (void)setDeleteButtonText:(NSString *)text;
- (void)setEnterPasscodeLabelText:(NSString *)text;

- (void)cancelButtonDisabled:(BOOL)disabled;

- (void)setBackgroundView:(UIView*)backgroundView;

- (void)processPin; //Called when the pin has reached maximum digits

@end

@protocol ABPadLockScreenDelegate <NSObject>
@required
- (void)unlockWasCancelledForPadLockScreenViewController:(AJTYKeyPadAbstractViewController *)padLockScreenViewController;

@end