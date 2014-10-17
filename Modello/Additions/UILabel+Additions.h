//
//  UILabel+Additions.h
//  Modello
//
//  Created by Ziad on 10/17/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Additions)

+ (void)updateLabels:(NSArray *)labels
         withObjects:(NSArray *)objects
                 key:(NSString *)key
             classes:(NSArray *)classes
        placeholders:(NSArray *)placeholders;

@end
