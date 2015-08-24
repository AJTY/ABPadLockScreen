//
//  AJTYKeyPadView.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYKeyPadView.h"
#import "AJTYKeyPadButton.h"
#import "ABPinSelectionView.h"
#import "ABPadButton.h"
#import "AJTYCallButton.h"
#import <AudioToolbox/AudioToolbox.h>
#define animationLength 0.15
#define IS_IPHONE4s ([UIScreen mainScreen].bounds.size.height==480)
#define IS_IPHONE5 ([UIScreen mainScreen].bounds.size.height>=568)
#define IS_IPAD ([UIScreen mainScreen].bounds.size.height==1024)
#define IS_IOS6_OR_LOWER (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)

@interface AJTYKeyPadView()

@property (nonatomic, assign) BOOL requiresRotationCorrection;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UIView* backgroundBlurringView;


- (void)setDefaultStyles;
- (void)prepareAppearance;
- (void)performLayout;
- (void)layoutTitleArea;
- (void)layoutButtonArea;

- (void)setUpButton:(UIButton *)button left:(CGFloat)left top:(CGFloat)top;

- (void)performAnimations:(void (^)(void))animations animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (CGFloat)correctWidth;
- (CGFloat)correctHeight;

@end

@implementation AJTYKeyPadView

@synthesize digitsArray = _digitsArray;
@synthesize test = _test;
#pragma mark -
#pragma mark - Init Methods
- (id)initWithFrame:(CGRect)frame complexPin:(BOOL)complexPin
{
    self = [self initWithFrame:frame];
    if (self)
    {
        _complexPin = complexPin;
		if(complexPin)
		{
            _digitsTextField = [[UITextField alloc]init];
			_digitsTextField.enabled = NO;
			_digitsTextField.textAlignment = NSTextAlignmentCenter;
			_digitsTextField.borderStyle = UITextBorderStyleNone;
			_digitsTextField.layer.borderWidth = 1.0f;
			_digitsTextField.layer.cornerRadius = 5.0f;
		}
    }
    return self;
}
- (void)setUpButton:(UIButton *)button left:(CGFloat)left top:(CGFloat)top
{
    if (IS_IPHONE4s) {
        button.frame = CGRectMake(left, top, 68, 68);
        [self.contentView addSubview:button];
        [self setRoundedView:button toDiameter:68];
        self.detailLabel.hidden = YES;

    }else if (IS_IPHONE5 ) {
        button.frame = CGRectMake(left, top, 70, 70);
        [self.contentView addSubview:button];
        [self setRoundedView:button toDiameter:70];
    }else{
        button.frame = CGRectMake(left, top, ABPadButtonWidth, ABPadButtonHeight);
        [self.contentView addSubview:button];
        [self setRoundedView:button toDiameter:75];
    }
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setDefaultStyles];
		_contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, MIN(frame.size.height, 568.0f))];
		_contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		_contentView.center = self.center;
		[self addSubview:_contentView];
        _requiresRotationCorrection = NO;
        _detailLabel = [self standardLabel];
        
        _buttonOne = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:1 letters:nil];
        _buttonTwo = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:2 letters:@"ABC"];
        _buttonThree = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:3 letters:@"DEF"];
        
        _buttonFour = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:4 letters:@"GHI"];
        _buttonFive = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:5 letters:@"JKL"];
        _buttonSix = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:6 letters:@"MNO"];
        
        _buttonSeven = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:7 letters:@"PQRS"];
        _buttonEight = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:8 letters:@"TUV"];
        _buttonNine = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:9 letters:@"WXYZ"];
        
        _buttonHash = [[AJTYKeyPadButton alloc]initWithFrame:CGRectZero numberString:@"#" letters:nil];
        _buttonZero = [[AJTYKeyPadButton alloc] initWithFrame:CGRectZero number:0 letters:@"+"];
        _buttonStar = [[AJTYKeyPadButton alloc]initWithFrame:CGRectZero numberString:@"*" letters:nil];


        _buttonCall = [[AJTYKeyPadButton alloc]initWithFrame:CGRectZero number:10 letters:@"CALL"];
                _buttonCall = [[AJTYCallButton alloc]initWithFrame:CGRectZero];

        for (ABPadButton * button in self.buttonArray) {
            if (self.buttonCall == button) {
                continue;
            }
            [button addTarget:self
                       action:@selector(buttonAction:)
             forControlEvents:UIControlEventTouchUpInside];
        }

        [self.buttonCall addTarget:self
                            action:@selector(callButtonAction:)
                  forControlEvents:UIControlEventTouchUpInside];


		UIButtonType buttonType = UIButtonTypeSystem;
		if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)
		{
			buttonType = UIButtonTypeCustom;
		}

        
		_okButton = [UIButton buttonWithType:buttonType];
        [_okButton setBackgroundImage:[UIImage imageNamed:@"backspace_icon"]
                             forState:UIControlStateNormal];



        [_okButton addTarget:self
                      action:@selector(deleteButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];

		_okButton.alpha = 0.0f;
		_okButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		
        // default to NO
        _complexPin = NO;
    }
    return self;
}

#pragma mark -
#pragma mark - Lifecycle Methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self performLayout];
	[self prepareAppearance];
}

#pragma mark -
#pragma mark - Public Methods
- (NSArray *)buttonArray
{
    return @[self.buttonCall,
             self.buttonHash,self.buttonZero, self.buttonStar,
             self.buttonOne, self.buttonTwo, self.buttonThree,
             self.buttonFour, self.buttonFive, self.buttonSix,
             self.buttonSeven, self.buttonEight, self.buttonNine];
}


- (void)showDeleteButton:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
	__weak AJTYKeyPadView *weakSelf = self;
    [self performAnimations:^{
        weakSelf.okButton.alpha = show ? 1.0f : 0.0f;
    } animated:animated completion:completion];
}

- (void)updateDetailLabelWithString:(NSString *)string animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    CGFloat length = (animated) ? animationLength : 0.0;
    CGFloat labelWidth = 15; // padding
	if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
		labelWidth += [string sizeWithAttributes:@{NSFontAttributeName:self.detailLabelFont}].width;
	else
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        labelWidth += [string sizeWithFont: self.detailLabelFont].width;
#pragma clang diagnostic pop
    
    CATransition *animation = [CATransition animation];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.type = kCATransitionFade;
    animation.duration = length;
    [self.detailLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
    
    self.detailLabel.text = string;

    if (IS_IPHONE4s) {
        self.detailLabel.frame = CGRectMake(([self correctWidth]/2) - 150,
                                            self.digitsTextField.frame.origin.y + self.digitsTextField.frame.size.height,
                                            300,
                                            20);

    }
    self.detailLabel.frame = CGRectMake(([self correctWidth]/2) - 150,
                                        self.digitsTextField.frame.origin.y + self.digitsTextField.frame.size.height + 10,
                                        300,
                                        23);
}

- (void)lockViewAnimated:(BOOL)animated withMessage:(NSString *)message completion:(void (^)(BOOL))completion
{
    [self performAnimations:^{
        self.detailLabel.text = message;
        for (UIButton *button in [self buttonArray])
        {
            button.alpha = 0.2f;
            button.userInteractionEnabled = NO;
        }

        for (ABPinSelectionView *view in self.digitsArray) {
            view.alpha = 0.0f;
        }
    } animated:animated completion:completion];
}

- (void)lockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [self performAnimations:^{
        for (UIButton *button in [self buttonArray])
        {
            button.alpha = 0.2f;
            button.userInteractionEnabled = NO;
        }

        for (ABPinSelectionView *view in self.digitsArray) {
            view.alpha = 0.0f;
        }
    } animated:animated completion:completion];
}

- (void)unlockViewAnimated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [self performAnimations:^{
        self.detailLabel.text = @"";
        for (UIButton *button in [self buttonArray])
        {
            button.alpha = 1.0f;
            button.userInteractionEnabled = YES;
        }

        for (ABPinSelectionView *view in self.digitsArray) {
            view.alpha = 1.0f;
        }
    } animated:animated completion:completion];
}

- (void)animateFailureNotification
{
	[self _animateFailureNotificationDirection:-35];
}

- (void)_animateFailureNotificationDirection:(CGFloat)direction
{
	[UIView animateWithDuration:0.08 animations:^{
		
		CGAffineTransform transform = CGAffineTransformMakeTranslation(direction, 0);
		
		if(self.isComplexPin)
		{
			self.digitsTextField.layer.affineTransform = transform;
		}
		else
		{
			for (ABPinSelectionView *view in self.digitsArray)
			{
				view.layer.affineTransform = transform;
			}
		}
	} completion:^(BOOL finished) {
		if(fabs(direction) < 1) {
			if(self.isComplexPin)
			{
				self.digitsTextField.layer.affineTransform = CGAffineTransformIdentity;
			}
			else
			{
				for (ABPinSelectionView *view in self.digitsArray)
				{
					view.layer.affineTransform = CGAffineTransformIdentity;
				}
			}
			return;
		}
		[self _animateFailureNotificationDirection:-1 * direction / 2];
	}];
}

- (void)resetAnimated:(BOOL)animated
{
    for (ABPinSelectionView *view in self.digitsArray)
    {
        [view setSelected:NO animated:animated completion:nil];
    }
    
	[self showDeleteButton:NO animated:animated completion:nil];
	
//	[self updatePinTextfieldWithLength:0];
}


#pragma mark - Button Actions
-(void) buttonAction:(id)sender
{
    ABPadButton * button = sender;
    NSLog(@"Button Clicked");
    _digitsTextField.text = [NSString stringWithFormat:@"%@%@", self.digitsTextField.text, button.numberLabel.text];
    [self showDeleteButton:YES
              animated:YES
            completion:^(BOOL finished) {
                ;
            }];
}


- (void) callButtonAction:(id)sender
{
    ABPadButton * button = sender;

    if (button.layer.backgroundColor == [UIColor redColor].CGColor) {
        [UIView animateWithDuration:0.6f delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.autoresizesSubviews = NO;
            [button setTransform:CGAffineTransformRotate(button.transform, -(131 * M_PI/180))];
            button.layer.backgroundColor = [UIColor colorWithRed:0.16 green:0.84 blue:0.41 alpha:1].CGColor;
        } completion:^(BOOL finished) {

            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.ajty.hipmo", 0);

            dispatch_async(backgroundQueue, ^{
                [self updateDetailLabelWithString:@"Call Ended"
                                         animated:YES
                                       completion:^(BOOL finished) {
                                       }];
                sleep(2);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.detailLabel.text isEqual:@"Call Ended"]) {
                        [self updateDetailLabelWithString:@""
                                                 animated:YES
                                               completion:nil];
                        self.digitsTextField.text = @"";
                    }
                });    
            });
            [self updateDetailLabelWithString:@""
                                     animated:YES
                                   completion:nil];
        }];
    }else{
        [UIView animateWithDuration:0.6f delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            button.autoresizesSubviews = NO;
            [button setTransform:CGAffineTransformRotate(button.transform, (131 * M_PI/180))];
            button.layer.backgroundColor = [UIColor redColor].CGColor;
        } completion:^(BOOL finished) {
            [self updateDetailLabelWithString:@"Calling..." animated:YES completion:^(BOOL finished) {
        #warning implement Calling HERE;


            }];
        }];


    }


    [self.test performSelector:@selector(callButtonTriggered)];

    if([self.test respondsToSelector:@selector(callButtonTriggered)]) {
        [_test callButtonTriggered];
    }

}

- (void) deleteButtonAction:(id)sender
{

    if ([_digitsTextField.text length] == 1) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self showDeleteButton:NO
                      animated:YES
                    completion:^(BOOL finished) {
                        [self animateFailureNotification];
                    }];
    }

    _digitsTextField.text = [_digitsTextField.text substringToIndex:[_digitsTextField.text length]-1];

}



- (void)setBackgroundView:(UIView *)backgroundView
{
	[_backgroundView removeFromSuperview];
	_backgroundView = backgroundView;

	if(_backgroundView == nil)
	{
		[_backgroundBlurringView setHidden:YES];
	}
	else
	{
		if(_backgroundBlurringView == nil)
		{
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) { // iOS 8
                UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleLight];
                _backgroundBlurringView = [[UIVisualEffectView alloc] initWithEffect: blur];
            }
            else if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
			{
				_backgroundBlurringView = [[UINavigationBar alloc] initWithFrame:self.bounds];
				[(UINavigationBar*)_backgroundBlurringView setBarStyle: UIBarStyleBlack];
			}
			else
			{
				_backgroundBlurringView = [[UIView alloc] initWithFrame:self.bounds];
				_backgroundBlurringView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
			}
            _backgroundBlurringView.frame = self.frame;
			_backgroundBlurringView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[self insertSubview:_backgroundBlurringView belowSubview:_contentView];
		}
		
		[_backgroundBlurringView setHidden:NO];
		[_backgroundView setFrame:self.bounds];
		[_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

        [self insertSubview:_backgroundView belowSubview:_backgroundBlurringView];
	}
}

#pragma mark -
#pragma mark - Helper Methods
- (void)setDefaultStyles
{
    _enterPasscodeLabelFont = [UIFont systemFontOfSize:18];
    _detailLabelFont = [UIFont systemFontOfSize:14];
    
    _labelColor = [UIColor whiteColor];
}

- (void)prepareAppearance
{

    
	self.digitsTextField.textColor = [(AJTYKeyPadButton*)self.buttonZero borderColor];
	self.digitsTextField.layer.borderColor = [(AJTYKeyPadButton*)self.buttonZero borderColor].CGColor;
	
	
    self.detailLabel.textColor = self.labelColor;
    self.detailLabel.font = self.detailLabelFont;


	[self.okButton setTitleColor:self.labelColor forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark - Layout Methods
- (void)performLayout
{
    [self layoutTitleArea];
    [self layoutButtonArea];
    _requiresRotationCorrection = YES;
}

- (void)layoutTitleArea
{
    CGFloat top = NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 ? 15 : 65;
	
	if(!IS_IPHONE5)
	{
		top = NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 ? 5 : 20;
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		top = NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1 ? 30 : 80;;
	}
	




	if(self.isComplexPin)
	{
        if (IS_IPHONE4s) {
            CGFloat textFieldWidth = self.frame.size.width - 88;
            _digitsTextField.frame = CGRectMake((self.correctWidth / 2) - (textFieldWidth / 2),
                                                self.frame.origin.y + 10,
                                                textFieldWidth,
                                                20);

            [self.contentView addSubview:_digitsTextField];
            _okButton.frame = CGRectMake(_digitsTextField.frame.origin.x + _digitsTextField.frame.size.width + 10,
                                         (_digitsTextField.frame.origin.y + _digitsTextField.frame.size.height) / 2,
                                         _digitsTextField.frame.size.height,
                                         _digitsTextField.frame.size.height);
        }

        if (IS_IPHONE5) {
            CGFloat textFieldWidth = self.frame.size.width - 88;
            _digitsTextField.frame = CGRectMake((self.correctWidth / 2) - (textFieldWidth / 2),
                                                self.frame.origin.y + 44,
                                                textFieldWidth,
                                                35);

            [self.contentView addSubview:_digitsTextField];
            _okButton.frame = CGRectMake(_digitsTextField.frame.origin.x + _digitsTextField.frame.size.width + 10,
                                         (_digitsTextField.frame.origin.y + _digitsTextField.frame.size.height) / 2,
                                         _digitsTextField.frame.size.height,
                                         _digitsTextField.frame.size.height);
        }

		CGFloat textFieldWidth = self.contentView.bounds.size.width - 88;
        _digitsTextField.frame = CGRectMake((self.correctWidth / 2) - (textFieldWidth / 2),
                                            self.frame.origin.y + 44,
                                            textFieldWidth,
                                            50);
        [self.contentView addSubview:_digitsTextField];



        _okButton.frame = CGRectMake(_digitsTextField.frame.origin.x + _digitsTextField.frame.size.width + 10,
                                     _digitsTextField.frame.origin.y + (_digitsTextField.frame.size.height) / 2 - (_digitsTextField.frame.size.height/4),
                                      _digitsTextField.frame.size.height/2 + 7,
                                     _digitsTextField.frame.size.height/2);


        [self.contentView addSubview:_okButton];
	}

    self.detailLabel.frame = CGRectMake(([self correctWidth]/2) - 150,
                                        self.digitsTextField.frame.origin.y + self.digitsTextField.frame.size.height + 10,
                                        300,
                                        23);

    [self.contentView addSubview:self.detailLabel];
}

- (void)layoutButtonArea
{

    CGFloat horizontalButtonPadding;
    CGFloat verticalButtonPadding;
    CGFloat buttonRowWidth;
    CGFloat lefButtonLeft;
    CGFloat centerButtonLeft;
    CGFloat rightButtonLeft;
    CGFloat topRowTop;
    CGFloat middleRowTop;
    CGFloat bottomRowTop;
    CGFloat zeroRowTop;
    CGFloat callRowTop;


    if (IS_IPHONE5) {

        horizontalButtonPadding = 20;
        verticalButtonPadding = 5;

        buttonRowWidth = (70 * 3) + (horizontalButtonPadding * 2);
        lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
        centerButtonLeft = lefButtonLeft + 70 + horizontalButtonPadding;
        rightButtonLeft = centerButtonLeft + 70 + horizontalButtonPadding;
        topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 0;
        middleRowTop = topRowTop + 70 + verticalButtonPadding;
        bottomRowTop = middleRowTop + 70 + verticalButtonPadding;
        zeroRowTop = bottomRowTop + 70 + verticalButtonPadding;
        callRowTop = zeroRowTop + 70 + verticalButtonPadding;

    }else if (IS_IPHONE4s){
        horizontalButtonPadding = 20;
        verticalButtonPadding = 5;

        buttonRowWidth = (68 * 3) + (horizontalButtonPadding * 2);
        lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
        centerButtonLeft = lefButtonLeft + 68 + horizontalButtonPadding;
        rightButtonLeft = centerButtonLeft + 68 + horizontalButtonPadding;
        topRowTop = self.digitsTextField.frame.origin.y + self.digitsTextField.frame.size.height + 0;
        middleRowTop = topRowTop + 68 + verticalButtonPadding;
        bottomRowTop = middleRowTop + 68 + verticalButtonPadding;
        zeroRowTop = bottomRowTop + 68 + verticalButtonPadding;
        callRowTop = zeroRowTop + 68 + verticalButtonPadding;
    }else if (IS_IPAD){
        horizontalButtonPadding = 20;
        verticalButtonPadding = 10;
        buttonRowWidth = (ABPadButtonWidth * 3) + (horizontalButtonPadding * 2);
        lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
        centerButtonLeft = lefButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
        rightButtonLeft = centerButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
        topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 10;
        middleRowTop = topRowTop + ABPadButtonHeight + verticalButtonPadding;
        bottomRowTop = middleRowTop + ABPadButtonHeight + verticalButtonPadding;
        zeroRowTop = bottomRowTop + ABPadButtonHeight + verticalButtonPadding;
        callRowTop = zeroRowTop + ABPadButtonHeight + verticalButtonPadding;
    } else{
//        horizontalButtonPadding = 20;
//        verticalButtonPadding = 10;
//        buttonRowWidth = (ABPadButtonWidth * 3) + (horizontalButtonPadding * 2);
//        lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
//        centerButtonLeft = lefButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
//        rightButtonLeft = centerButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
//        topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 0;
//        middleRowTop = topRowTop + ABPadButtonHeight + verticalButtonPadding;
//        bottomRowTop = middleRowTop + ABPadButtonHeight + verticalButtonPadding;
//        zeroRowTop = bottomRowTop + ABPadButtonHeight + verticalButtonPadding;
//        callRowTop = zeroRowTop + ABPadButtonHeight + verticalButtonPadding;

        horizontalButtonPadding = 20;
        verticalButtonPadding = 5;

        buttonRowWidth = (70 * 3) + (horizontalButtonPadding * 2);
        lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
        centerButtonLeft = lefButtonLeft + 70 + horizontalButtonPadding;
        rightButtonLeft = centerButtonLeft + 70 + horizontalButtonPadding;

        topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 10;
        middleRowTop = topRowTop + 70 + verticalButtonPadding;
        bottomRowTop = middleRowTop + 70 + verticalButtonPadding;
        zeroRowTop = bottomRowTop + 70 + verticalButtonPadding;
        callRowTop = zeroRowTop + 70 + verticalButtonPadding;

    }
    if (!IS_IPHONE5 && !IS_IPHONE4s) topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 10;



    [self setUpButton:self.buttonOne left:lefButtonLeft top:topRowTop];
    [self setUpButton:self.buttonTwo left:centerButtonLeft top:topRowTop];
    [self setUpButton:self.buttonThree left:rightButtonLeft top:topRowTop];
    
    [self setUpButton:self.buttonFour left:lefButtonLeft top:middleRowTop];
    [self setUpButton:self.buttonFive left:centerButtonLeft top:middleRowTop];
    [self setUpButton:self.buttonSix left:rightButtonLeft top:middleRowTop];
    
    [self setUpButton:self.buttonSeven left:lefButtonLeft top:bottomRowTop];
    [self setUpButton:self.buttonEight left:centerButtonLeft top:bottomRowTop];
    [self setUpButton:self.buttonNine left:rightButtonLeft top:bottomRowTop];
    
    [self setUpButton:self.buttonZero left:centerButtonLeft top:zeroRowTop];
    [self setUpButton:self.buttonHash left:lefButtonLeft top:zeroRowTop];
    [self setUpButton:self.buttonStar left:rightButtonLeft top:zeroRowTop];

    [self setUpButton:self.buttonCall left:centerButtonLeft top:callRowTop];
    
	CGRect deleteCancelButtonFrame = CGRectMake(rightButtonLeft, zeroRowTop + ABPadButtonHeight + 25, ABPadButtonWidth, 20);
	if(!IS_IPHONE5)
	{
		//Bring it higher for small device screens
		deleteCancelButtonFrame = CGRectMake(rightButtonLeft, zeroRowTop + ABPadButtonHeight - 20, ABPadButtonWidth, 20);
	}
	
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		//Center it with zero button
		deleteCancelButtonFrame = CGRectMake(rightButtonLeft, zeroRowTop + (ABPadButtonHeight / 2 - 10), ABPadButtonWidth, 20);
	}
	
}

- (void)performAnimations:(void (^)(void))animations animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    CGFloat length = (animated) ? animationLength : 0.0f;
    
    [UIView animateWithDuration:length delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                     animations:animations
                     completion:completion];
}

#pragma mark -
#pragma mark - Orientation height helpers
- (CGFloat)correctWidth
{
	return _contentView.bounds.size.width;
}

- (CGFloat)correctHeight
{
    return _contentView.bounds.size.height;

}

#pragma mark -
#pragma mark -  View Methods
- (UILabel *)standardLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = _labelColor;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

- (void)setRoundedView:(UIView *)roundedView toDiameter:(CGFloat)newSize;
{
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.clipsToBounds = YES;
    roundedView.layer.cornerRadius = newSize / 2.0;
}

#pragma mark - Delegate Methods





@end