//
//  UILabel+Additions.m
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel (Additions)

+ (void)updateLabels:(NSArray *)labels
         withObjects:(NSArray *)objects
                 key:(NSString *)key
             classes:(NSArray *)classes
        placeholders:(NSArray *)placeholders
{
    /* Collect the infos chosen */
    NSMutableArray *names = [NSMutableArray new];
    [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [names addObject:obj[@"name"]];
    }];
    
    /* Update the placeholder witth the infos chosen */
    NSUInteger index = [classes indexOfObject:key];
    UILabel *label = labels[index + 1];
    /* Change the color of the label and put the chosen infos */
    if ([names count] > 0) {
        [label setTextColor:[UIColor blackColor]];
        [label setText:[names componentsJoinedByString:@", "]];
        
        /* If there is no info chosen, show the placeholder */
    } else {
        [label setTextColor:[UIColor lightGrayColor]];
        [label setText:placeholders[index + 1]];
    }
}

@end
