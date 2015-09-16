//
//  AJTYCallButton.m
//  ABPadLockScreenDemo
//
//  Created by Tomas Sykora, jr. on 13/08/15.
//  Copyright (c) 2015 Aron Bury. All rights reserved.
//

#import "AJTYCallButton.h"
#import <QuartzCore/QuartzCore.h>

#define animationLength 0.15

@interface AJTYCallButton()

@property (nonatomic, strong) UIView *selectedView;

- (void)setDefaultStyles;
- (void)prepareApperance;

@end

@implementation AJTYCallButton

#pragma mark - Init Methods
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setDefaultStyles];
        [self setBackgroundImage:[UIImage imageNamed:@"hang_up"] forState:UIControlStateNormal];
    }
    return self;
}

#pragma mark - Lifecycle Methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self prepareApperance];

}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self prepareApperance];
}

#pragma mark - Helper Methods
- (void)setDefaultStyles
{
    _borderColor = [UIColor whiteColor];
    _selectedColor = [UIColor lightGrayColor];

}

- (void)prepareApperance
{
    self.selectedView.backgroundColor = self.selectedColor;
    self.layer.borderColor = [self.borderColor CGColor];
}

@end