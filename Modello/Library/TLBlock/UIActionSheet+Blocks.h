//
//  UIActionSheet+Blocks.h
//  TLActionSheetBlocks
//
//  Created by Ziad on 7/20/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (Blocks)

+ (void)showIn:(id)target title:(NSString *)title
              cancelButtonTitle:(NSString *)cancelButtonTitle
         destructiveButtonTitle:(NSString *)destructiveButtonTitle
              otherButtonTitles:(NSArray *)otherButtonTitles
              completionHandler:(void(^)(UIActionSheet *actionSheet, NSInteger buttonIndex))handler;

@end
