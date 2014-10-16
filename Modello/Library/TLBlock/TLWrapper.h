//
//  TLWrapper.h
//  TLWrapper
//
//  Created by Ziad on 7/20/14.
//  Copyright (c) 2014 TAMIN LAB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface TLWrapper : NSObject<UIAlertViewDelegate,UIActionSheetDelegate>
@property (copy) void(^completionHandler)(id view, NSInteger buttonIndex);
@end
