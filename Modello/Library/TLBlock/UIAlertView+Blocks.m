//
//  UIAlertView+Blocks.m
//  TLAlertBlocks
//
//  Created by Ziad on 7/19/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import "UIAlertView+Blocks.h"

#import <objc/runtime.h>
#import "TLWrapper.h"

static const char kTLAlertWrapper;
@implementation UIAlertView (Blocks)

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
                style:(UIAlertViewStyle)style
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
    completionHandler:(void(^)(UIAlertView *alertView, NSInteger buttonIndex))handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    [alert setAlertViewStyle:style];
    [alert textFieldAtIndex:0].autocapitalizationType = UITextAutocapitalizationTypeWords;
    [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [alert addButtonWithTitle:title];
    }];
    
    // Wrapper
    TLWrapper *wrapper = [[TLWrapper alloc] init];
    [wrapper setCompletionHandler:handler];
    [alert setDelegate:wrapper];
    
    objc_setAssociatedObject(self, &kTLAlertWrapper, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [alert show];
}

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    completionHandler:(void(^)(UIAlertView *alertView))handler
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    [alert show];
    if (handler != NULL) handler(alert);
}

@end
