//
//  Manager.m
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "Manager.h"

#import "Builder.h"

@implementation Manager

#pragma mark -

+ (BOOL)objects:(NSArray *)objects contain:(PFObject *)object
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", object[@"name"]];
    return ([[objects filteredArrayUsingPredicate:predicate] count] > 0);
}

#pragma mark - Project

+ (void)createProjectWithName:(NSString *)name
            completionHandler:(void(^)(PFObject *object, NSError *error))handler
{
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    [project setValue:name forKey:@"name"];
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        handler(project, error);
    }];
}

+ (void)updateProject:(PFObject *)project
              newInfo:(NSDictionary *)newInfo
    completionHandler:(void(^)(NSError *error))handler
{
    project = [Builder updateProject:project withInfo:newInfo];
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         handler(error);
    }];
}

#pragma mark - ScreenShot

+ (void)createScreenshots:(NSArray *)screenshots
                inProject:(PFObject *)project
        completionHandler:(void(^)(NSError *error))handler
{
    // Create Screenshots
    NSMutableArray *screenshotsObject = [NSMutableArray new];
    [screenshots enumerateObjectsUsingBlock:^(NSDictionary *infos, NSUInteger idx, BOOL *stop) {
        
        /* Build Screenshot */
        PFObject *screenshot = [Builder createScreenshotFromInfo:infos parent:project];
        [screenshotsObject addObject:screenshot];
    }];
    
    [PFObject saveAllInBackground:screenshotsObject block:^(BOOL succeeded, NSError *error) {
        handler(error);
    }];
}

@end
