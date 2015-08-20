//
//  AJTYKeyPadView.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#define SIMPLE_PIN_LENGTH 4

@class ABPinSelectionView;
@class AJTYKeyPadViewController;
#import "AJTYKeyPadAbstractViewController.h"
#import "AJTYKeyPadViewController.h"

@interface AJTYKeyPadView : UIView <UITextFieldDelegate>
@property (nonatomic, weak, readonly) id<AJTYKeyPadViewControllerDelegate> test;
@property (nonatomic, strong) UIFont * enterPasscodeLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont * detailLabelFont        UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont * deleteCancelLabelFont  UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *labelColor             UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIView* backgroundView;


@property (nonatomic, strong, readonly) UILabel  *detailLabel;

@property (nonatomic, strong, readonly) UIButton *buttonOne;
@property (nonatomic, strong, readonly) UIButton *buttonTwo;
@property (nonatomic, strong, readonly) UIButton *buttonThree;

@property (nonatomic, strong, readonly) UIButton *buttonFour;
@property (nonatomic, strong, readonly) UIButton *buttonFive;
@property (nonatomic, strong, readonly) UIButton *buttonSix;

@property (nonatomic, strong, readonly) UIButton *buttonSeven;
@property (nonatomic, strong, readonly) UIButton *buttonEight;
@property (nonatomic, strong, readonly) UIButton *buttonNine;

@property (nonatomic, strong, readonly) UIButton *buttonZero;

@property (nonatomic, strong, readonly) UIButton *buttonHash;
@property (nonatomic, strong, readonly) UIButton *buttonStar;
@property (nonatomic, strong, readonly) UIButton *buttonCall;

@property (nonatomic, strong, readonly) UIButton *okButton;

/*
 Lazy loaded array that returns all the buttons ordered from 0-9
 */
- (NSArray *)buttonArray;

/*
 The following are used to decide how to display the padlock view - complex (text field) or simple (digits)
 */
@property (nonatomic, assign, readonly, getter = isComplexPin) BOOL complexPin;
@property (nonatomic, strong, readonly) NSArray *digitsArray;
@property (nonatomic, strong, readonly) UITextField *digitsTextField;


- (void)showDeleteButton:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)updateDetailLabelWithString:(NSString *)string animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)lockViewAnimated:(BOOL)animated withMessage:(NSString*)message completion:(void (^)(BOOL finished))completion;
- (void)unlockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (void)lockViewAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)animateFailureNotification;
- (void)resetAnimated:(BOOL)animated;


- (id)initWithFrame:(CGRect)frame complexPin:(BOOL)complexPin;


@end