//
//  AJTYKeyPadAbstractViewController.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

@protocol AJTYKeyPadViewDelegate;
@class AJTYKeyPadView;

@interface AJTYKeyPadAbstractViewController : UIViewController
{
    AJTYKeyPadView* lockScreenView;
}

@property (nonatomic, strong) NSString *currentPin;
@property (nonatomic, weak) id<AJTYKeyPadViewDelegate> delegate;
@property (nonatomic, readonly, getter = isComplexPin) BOOL complexPin;
@property (nonatomic, assign) BOOL tapSoundEnabled;
@property (nonatomic, assign) BOOL errorVibrateEnabled;
@property (nonatomic, strong) NSDate * startDate;
@property (nonatomic, strong) NSTimer * timer;

- (id)initWithComplexPin:(BOOL)complexPin;

#pragma mark - Visual support
- (void)setLockScreenTitle:(NSString *)title;
- (void)setBackgroundView:(UIView*)backgroundView;



@end

#pragma mark - Protocol
@protocol AJTYKeyPadViewDelegate <NSObject>
@required

- (void) callStartedDelegateWithNumber:(NSString *) number;
- (void) callEndedDelegateWithTime:(NSString *)timeString;
@end