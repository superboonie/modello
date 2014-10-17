//
//  Manager.h
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "UIAlertView+Blocks.h"

@interface Manager : NSObject

+ (BOOL)objects:(NSArray *)objects
        contain:(PFObject *)object;

+ (void)createProjectWithName:(NSString *)name
            completionHandler:(void(^)(PFObject *object, NSError *error))handler;

+ (void)updateProject:(PFObject *)project
              newInfo:(NSDictionary *)info
    completionHandler:(void(^)(NSError *error))handler;

+ (void)createScreenshots:(NSArray *)screenshots
                inProject:(PFObject *)project
        completionHandler:(void(^)(NSError *error))handler;

+ (void)fetchProjectInfo:(PFObject *)project
       completionHandler:(void(^)(NSDictionary *projectInfo, NSArray *screenshotInfo, NSError *error))handler;

@end
