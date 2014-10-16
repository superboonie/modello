//
//  PlaceholderView.h
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceholderView : UIView

+ (void)showPlaceholderWithFrame:(CGRect)frame inView:(UIView *)view;
+ (void)hidePlaceholder;

@end
