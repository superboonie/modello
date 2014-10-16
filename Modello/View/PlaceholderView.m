//
//  PlaceholderView.m
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "PlaceholderView.h"

@interface PlaceholderView ()
@property (nonatomic, strong) UILabel *noDataLabel;
@end

@implementation PlaceholderView

static PlaceholderView *placeholderView_ = nil;

+ (void)showPlaceholderWithFrame:(CGRect)frame inView:(UIView *)view
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        placeholderView_= [[PlaceholderView alloc] initWithFrame:frame];
    });
    
    [view addSubview:placeholderView_];
}

+ (void)hidePlaceholder
{
    [placeholderView_ removeFromSuperview];
}

#pragma mark - Life Cycle 

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), 30.f)];
    [self.noDataLabel setCenter:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds) - 30.f)];
    [self.noDataLabel setTextAlignment:NSTextAlignmentCenter];
    [self.noDataLabel setText:@"No project found"];
    [self addSubview:self.noDataLabel];
}

@end
