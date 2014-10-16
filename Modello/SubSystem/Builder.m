//
//  Builder.m
//  Modello
//
//  Created by Ziad on 10/16/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "Builder.h"

@implementation Builder

+ (PFObject *)createScreenshotFromInfo:(NSDictionary *)info
                          parent:(PFObject *)parent
{
    /* Retrieve the info held */
    PFObject *screenshot = [PFObject objectWithClassName:@"ScreenShot"];
    
    // Parent
    PFRelation *relation = [screenshot relationForKey:@"parent"];
    [relation addObject:parent];
    
    // Image, UX, UI
    [info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSArray class]]) {
            PFRelation *relation = [screenshot relationForKey:[key lowercaseString]];
            [(NSArray *)obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [relation addObject:obj];
            }];
            
        } else {
            [screenshot setValue:[PFFile fileWithData:obj] forKey:[key lowercaseString]];
        }
    }];

    return screenshot;
}

+ (PFObject *)updateProject:(PFObject *)project withInfo:(NSDictionary *)newInfo
{
    [newInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PFRelation *relation = [project relationForKey:[key lowercaseString]];
        [(NSArray *)obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [relation addObject:obj];
        }];
    }];
    
    return project;
}

@end
