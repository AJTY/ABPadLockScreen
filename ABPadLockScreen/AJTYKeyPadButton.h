//
//  AJTYKeyPadButton.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

@interface AJTYKeyPadButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame number:(NSInteger)number letters:(NSString *)letters;
- (instancetype)initWithFrame:(CGRect)frame numberString:(NSString *)number letters:(NSString *)letters;

@property (nonatomic, strong, readonly) UILabel *numberLabel;
@property (nonatomic, strong, readonly) UILabel *lettersLabel;

@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *hightlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *numberLabelFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *letterLabelFont UI_APPEARANCE_SELECTOR;

@end

extern CGFloat const ABPadButtonHeight;
extern CGFloat const ABPadButtonWidth;