//
//  Manager.m
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "Manager.h"

#import "PFObject+Additions.h"
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

+ (void)fetchScreenShotsOfProject:(PFObject *)project
                completionHandler:(void(^)(NSArray *objects, NSError *error))handler
{
    NSMutableArray *screenshotsInfo = [NSMutableArray new];
    PFQuery *query = [PFQuery queryWithClassName:@"ScreenShot"];
    [query whereKey:@"parent" equalTo:project];
    [query findObjectsInBackgroundWithBlock:^(NSArray *screenshots, NSError *error) {
        
        if (![screenshots count]) {
            handler(screenshotsInfo, nil);
            return;
        }
        
        [screenshots enumerateObjectsUsingBlock:^(PFObject *screenshot, NSUInteger idx, BOOL *stop) {
            
            PFFile *file = screenshot[@"imagefile"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                NSMutableDictionary *parsedScreenshot = [@{@"imageFile": data} mutableCopy];
                
                /* */
                [screenshot fetchObjectsInRelationWithKeys:@[@"UserExperience", @"UserInterface"]
                                         complationHandler:^(NSDictionary *objects, NSError *error) {
                                             
                                             if (error) {
                                                 handler(nil, error);
                                                 return;
                                             }
                                             
                                             /* */
                                             [parsedScreenshot addEntriesFromDictionary:objects];
                                             [screenshotsInfo addObject:parsedScreenshot];
                                             
                                             if ([screenshotsInfo count] == [screenshots count]) {
                                                 handler(screenshotsInfo, nil);
                                             }
                                         }];
            }];
            
        }];
    }];
}

+ (void)fetchProjectInfo:(PFObject *)project
       completionHandler:(void(^)(NSDictionary *projectInfo, NSArray *screenshotInfo, NSError *error))handler
{
    NSMutableDictionary *projectInfo = [NSMutableDictionary new];
    [project fetchObjectsInRelationWithKeys:@[@"Platform", @"Category"]
                          complationHandler:^(NSDictionary *objects, NSError *error) {
                              [projectInfo addEntriesFromDictionary:objects];
                            
                              [Manager fetchScreenShotsOfProject:project
                                               completionHandler:^(NSArray *screenshotInfo, NSError *error) {
                                                   handler(projectInfo, screenshotInfo, error);
                                               }];
                          }];
}

@end
