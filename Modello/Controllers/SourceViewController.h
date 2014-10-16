//
//  SourceViewController.h
//  Modello
//
//  Created by Ziad on 10/12/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Manager.h"

@interface SourceViewController : PFQueryTableViewController
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSMutableArray *selectedObjects;
@end
