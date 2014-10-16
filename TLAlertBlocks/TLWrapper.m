//
//  TLWrapper.m
//  Blanee
//
//  Created by Ziad on 7/20/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import "TLWrapper.h"


@implementation TLWrapper

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionHandler)
        self.completionHandler(alertView, buttonIndex);
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (self.completionHandler)
        self.completionHandler(alertView, alertView.cancelButtonIndex);
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.completionHandler)
        self.completionHandler(actionSheet, buttonIndex);
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if (self.completionHandler)
        self.completionHandler(actionSheet, actionSheet.cancelButtonIndex);
}

@end
