//
//  Manager.m
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "Manager.h"

@implementation Manager

+ (void)findObjectsOfSource:(NSString *)source
          completionHandler:(void(^)(NSArray *objects, NSError *error))handler
{
    PFQuery *query = [PFQuery queryWithClassName:source];
    [query orderByAscending:@"name"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        handler(objects, error);
    }];
}

+ (void)createProjectWithName:(NSString *)name
            completionHandler:(void(^)(PFObject *object, NSError *error))handler
{
    PFObject *project = [PFObject objectWithClassName:@"Project"];
    [project setValue:name forKey:@"name"];
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        handler(project, error);
    }];
}

+ (void)createScreenshots:(NSArray *)screenshots
                       inProject:(PFObject *)project
               completionHandler:(void(^)(NSError *error))handler
{
    // Create Screenshots
    NSMutableArray *screenshotsObject = [NSMutableArray new];
    [screenshots enumerateObjectsUsingBlock:^(NSDictionary *infos, NSUInteger idx, BOOL *stop) {
        
        /* Retrieve the info held */
        PFObject *screenshot = [PFObject objectWithClassName:@"ScreenShot"];
        
        // Parent
        PFRelation *relation = [screenshot relationForKey:@"parent"];
        [relation addObject:project];
        
        // Image, UX, UI
        [infos enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([obj isKindOfClass:[NSArray class]]) {
                
                PFRelation *relation = [screenshot relationForKey:[key lowercaseString]];
                [(NSArray *)obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [relation addObject:obj];
                }];
                
            } else {
                [screenshot setValue:[PFFile fileWithData:obj] forKey:[key lowercaseString]];
            }
        }];
        
        [screenshotsObject addObject:screenshot];
    }];
    
    [PFObject saveAllInBackground:screenshotsObject block:^(BOOL succeeded, NSError *error) {
        handler(error);
    }];
}

+ (void)updateProject:(PFObject *)project
              newInfo:(NSDictionary *)newInfo
    completionHandler:(void(^)(NSError *error))handler
{
    [newInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PFRelation *relation = [project relationForKey:[key lowercaseString]];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [relation addObject:obj];
        }];
    }];
    
    [project saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         handler(error);
    }];
}

@end
