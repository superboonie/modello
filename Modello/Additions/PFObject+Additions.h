//
//  PFObject+Additions.h
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (Additions)

- (void)fetchObjectsInRelationWithKey:(NSString *)key
                    complationHandler:(void(^)(NSArray *objects, NSError *error))handler;

- (void)fetchObjectsInRelationWithKeys:(NSArray *)keys
                     complationHandler:(void(^)(NSDictionary *objects, NSError *error))handler;
@end
