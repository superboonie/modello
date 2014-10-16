//
//  Builder.h
//  Modello
//
//  Created by Ziad on 10/16/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@interface Builder : NSObject

+ (PFObject *)createScreenshotFromInfo:(NSDictionary *)info
                                parent:(PFObject *)parent;

+ (PFObject *)updateProject:(PFObject *)project
             withInfo:(NSDictionary *)newInfo;

@end
