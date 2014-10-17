//
//  PFObject+Additions.m
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "PFObject+Additions.h"

@implementation PFObject (Additions)

- (void)fetchObjectsInRelationWithKey:(NSString *)key
                    complationHandler:(void(^)(NSArray *objects, NSError *error))handler
{
    PFRelation *relation = [self relationForKey:key];
    [relation.query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        handler(objects, error);
    }];
}

- (void)fetchObjectsInRelationWithKeys:(NSArray *)keys
                     complationHandler:(void (^)(NSDictionary *objects, NSError *error))handler
{
    NSMutableDictionary *objects_ = [NSMutableDictionary new];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        [self fetchObjectsInRelationWithKey:key.lowercaseString
                          complationHandler:^(NSArray *objects, NSError *error) {
                              [objects_ setValue:objects forKey:key];
                              
                              /* Stop fetching when an error has occured */
                              if (error) {
                                  handler(nil, error);
                                  *stop = YES;
                                  
                               /* Send objects retrieved */
                              } else if ([objects_ count] == [keys count]) {
                                  handler(objects_, nil);
                              }
                          }];
    }];
    
}

@end
