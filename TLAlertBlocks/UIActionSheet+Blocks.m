//
//  UIActionSheet+Blocks.m
//  TLActionSheetBlocks
//
//  Created by Ziad on 7/20/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import "UIActionSheet+Blocks.h"

#import <objc/runtime.h>
#import "TLWrapper.h"

static const char kTLActionSheetWrapper;
@implementation UIActionSheet (Blocks)

+ (void)showIn:(id)target title:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
         destructiveButtonTitle:(NSString *)destructiveButtonTitle
              otherButtonTitles:(NSArray *)otherButtonTitles
              completionHandler:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))handler;
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:nil];
    
    [otherButtonTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        [actionSheet addButtonWithTitle:title];
    }];
    
    [actionSheet addButtonWithTitle:cancelButtonTitle];
    [actionSheet setCancelButtonIndex:[otherButtonTitles count]];
    
    // Wrapper
    TLWrapper *wrapper = [[TLWrapper alloc] init];
    [wrapper setCompletionHandler:handler];
    [actionSheet setDelegate:wrapper];
    
    objc_setAssociatedObject(self, &kTLActionSheetWrapper, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    //
    if ([target isKindOfClass:[UITabBar class]]) {
        [actionSheet showFromTabBar:target];
        
    } else if ([target isKindOfClass:[UIToolbar class]]) {
        [actionSheet showFromToolbar:target];
        
    } else if ([target isKindOfClass:[UIView class]]) {
        [actionSheet showInView:target];
    }
    
}

@end
