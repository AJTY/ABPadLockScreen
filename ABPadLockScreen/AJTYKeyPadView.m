
#import "AJTYKeyPadView.h"
#import "AJTYKeyPadButton.h"
#import "ABPinSelectionView.h"
#import "ABPadButton.h"

#define animationLength 0.15
#define IS_IPHONE5 ([UIScreen mainScreen].bounds.size.height==568)
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
- (void)setUpPinSelectionView:(ABPinSelectionView *)selectionView left:(CGFloat)left top:(CGFloat)top;
- (void)performAnimations:(void (^)(void))animations animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (CGFloat)correctWidth;
- (CGFloat)correctHeight;

@end

@implementation AJTYKeyPadView

@synthesize digitsArray = _digitsArray;

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
//			_digitsTextField.secureTextEntry = YES;
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
    button.frame = CGRectMake(left, top, ABPadButtonWidth, ABPadButtonHeight);
    [self.contentView addSubview:button];
    [self setRoundedView:button toDiameter:75];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setDefaultStyles];

        self.enterPasscodeLabel.text = @"test";
		_contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, MIN(frame.size.height, 568.0f))];
		_contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		_contentView.center = self.center;
		[self addSubview:_contentView];
        
        _requiresRotationCorrection = NO;
        
        _enterPasscodeLabel = [self standardLabel];
        _enterPasscodeLabel.text = NSLocalizedString(@"Enter Passcode", @"");
        
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

        for (ABPadButton * button in self.buttonArray) {
            [button addTarget:self
                       action:@selector(buttonAction:)
             forControlEvents:UIControlEventTouchUpInside];
        }

		UIButtonType buttonType = UIButtonTypeSystem;
		if(NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)
		{
			buttonType = UIButtonTypeCustom;
		}

        
		_okButton = [UIButton buttonWithType:buttonType];

        [_okButton addTarget:self
                      action:@selector(deleteButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
		[_okButton setTitle:NSLocalizedString(@"x", @"") forState:UIControlStateNormal];
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





- (void)showOKButton:(BOOL)show animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
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

	CGFloat pinSelectionTop = self.enterPasscodeLabel.frame.origin.y + self.enterPasscodeLabel.frame.size.height + 17.5;
	
    self.detailLabel.frame = CGRectMake(([self correctWidth]/2) - 150, pinSelectionTop + 30, 300, 23);
}

- (void)lockViewAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
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
    
	[self showOKButton:NO animated:animated completion:nil];
	
	[self updatePinTextfieldWithLength:0];
}

-(void) buttonAction:(id)sender
{
    ABPadButton * button = sender;
    NSLog(@"Button Clicked");
    _digitsTextField.text = [NSString stringWithFormat:@"%@%ld", self.digitsTextField.text, (long)button.tag];
    [self showOKButton:YES
              animated:YES
            completion:^(BOOL finished) {
                ;
            }];
}

- (void) deleteButtonAction:(id)sender
{
    [self showOKButton:NO
              animated:YES
            completion:^(BOOL finished) {
                _digitsTextField.text = @"";
                [self animateFailureNotification];
            }];
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
    self.enterPasscodeLabel.textColor = self.labelColor;
    self.enterPasscodeLabel.font = self.enterPasscodeLabelFont;
    
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
	
    self.enterPasscodeLabel.frame = CGRectMake(([self correctWidth]/2) - 150, top, 300, 23);
#warning remove completely!!
    //    [self.contentView addSubview:self.enterPasscodeLabel];

	CGFloat pinSelectionTop = self.enterPasscodeLabel.frame.origin.y + self.enterPasscodeLabel.frame.size.height + 17.5;

	if(self.isComplexPin)
	{
		CGFloat textFieldWidth = self.frame.size.width - 88;

//CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)


        _digitsTextField.frame = CGRectMake((self.correctWidth / 2) - (textFieldWidth / 2), self.frame.origin.y + 44, textFieldWidth, 50);


        [self.contentView addSubview:_digitsTextField];
		
//		_okButton.frame = CGRectMake(self.frame.size.width - 40,
//                                     pinSelectionTop - 7.5f,
//                                     (self.correctWidth - _digitsTextField.frame.size.width) / 2 - 10,
//                                     30);

        _okButton.frame = CGRectMake(_digitsTextField.frame.origin.x + _digitsTextField.frame.size.width + 10,
                                     (_digitsTextField.frame.origin.y + _digitsTextField.frame.size.height) / 2,
                                     _digitsTextField.frame.size.height,
                                     _digitsTextField.frame.size.height);
#warning Remove completely!
		[self.contentView addSubview:_okButton];
	}
	else
	{
		CGFloat pinPadding = 25;
		CGFloat pinRowWidth = (ABPinSelectionViewWidth * SIMPLE_PIN_LENGTH) + (pinPadding * (SIMPLE_PIN_LENGTH - 1));
		
		CGFloat selectionViewLeft = ([self correctWidth]/2) - (pinRowWidth/2);
		
		for (ABPinSelectionView *view in self.digitsArray) {
			[self setUpPinSelectionView:view  left:selectionViewLeft top:pinSelectionTop];
			selectionViewLeft+=ABPinSelectionViewWidth + pinPadding;
		}
	}
	
    self.detailLabel.frame = CGRectMake(([self correctWidth]/2) - 150, self.digitsTextField.frame.origin.y + self.digitsTextField.frame.size.height + 10, 300, 23);
    [self.contentView addSubview:self.detailLabel];
}

- (void)layoutButtonArea
{
    CGFloat horizontalButtonPadding = 20;
    CGFloat verticalButtonPadding = 10;
    
    CGFloat buttonRowWidth = (ABPadButtonWidth * 3) + (horizontalButtonPadding * 2);
    
    CGFloat lefButtonLeft = ([self correctWidth]/2) - (buttonRowWidth/2) + 0.5;
    CGFloat centerButtonLeft = lefButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
    CGFloat rightButtonLeft = centerButtonLeft + ABPadButtonWidth + horizontalButtonPadding;
    #warning 0
    CGFloat topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 0;
    
    if (!IS_IPHONE5) topRowTop = self.detailLabel.frame.origin.y + self.detailLabel.frame.size.height + 10;
    
    CGFloat middleRowTop = topRowTop + ABPadButtonHeight + verticalButtonPadding;
    CGFloat bottomRowTop = middleRowTop + ABPadButtonHeight + verticalButtonPadding;
    CGFloat zeroRowTop = bottomRowTop + ABPadButtonHeight + verticalButtonPadding;
    CGFloat callRowTop = zeroRowTop + ABPadButtonHeight + verticalButtonPadding;
    
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

#pragma mark - UITextFieldDelegate Methods



@end