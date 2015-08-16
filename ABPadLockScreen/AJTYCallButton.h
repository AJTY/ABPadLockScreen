//
//  AJTYCallButton.h
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

@interface AJTYCallButton : UIButton

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *selectedColor UI_APPEARANCE_SELECTOR;

@end

extern CGFloat const ABPadButtonHeight;
extern CGFloat const ABPadButtonWidth;