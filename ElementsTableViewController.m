//
//  ElementsTableViewController.m
//  Modello
//
//  Created by Boon Chew on 10/1/14.
//  Copyright (c) 2014 ELC Technologies. All rights reserved.
//

#import "ElementsTableViewController.h"
#import "ArrayDataSource.h"

@interface ElementsTableViewController ()

@property (nonatomic, strong) NSArray *elementsDataSource;

@end

@implementation ElementsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupTableView];
}

- (void)setupTableView {
    self.elementsDataSource = @[
                                @"Action sheet", @"Activity indicator", @"Alert view",
                                @"Bar button item",
                                @"Button",
                                @"Collection view",
                                @"Date picker",
                                @"Image view",
                                @"Keyboard",
                                @"Label",
                                @"Mapkit view",
                                @"Navigation bar",
                                @"Page control", @"Picker view", @"Progress view",
                                @"Scroll view", @"Search bar", @"Segmented control", @"Slider", @"Stepper", @"Switch",
                                @"Tab bar", @"Table view", @"Table view cell - Disclosure indicator", @"Table view cell - Detail disclosure", @"Table view cell - Checkmark",
                                @"Table view cell - Detail",
                                @"Text field", @"Text view", @"Toolbar",
                                @"Web view"];
    
    self.tableView.dataSource = self.elementsDataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.elementsDataSource.count;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
