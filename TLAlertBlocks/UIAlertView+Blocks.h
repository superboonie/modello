//
//  UIAlertView+Blocks.h
//  TLAlertBlocks
//
//  Created by Ziad on 7/19/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Blocks)

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
                style:(UIAlertViewStyle)style
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
    completionHandler:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))handler;

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    completionHandler:(void(^)(UIAlertView *alertView))handler;

@end
