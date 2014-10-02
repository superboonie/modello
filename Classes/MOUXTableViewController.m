//
//  CategoryTableViewController.m
//  Modello
//
//  Created by Boon Chew on 10/1/14.
//  Copyright (c) 2014 ELC Technologies. All rights reserved.
//

#import "MOUXTableViewController.h"

@interface MOUXTableViewController ()

@property (nonatomic, strong) NSArray *datasource;

@end

@implementation MOUXTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self setupTableView];
}

- (void)setupTableView {
    self.datasource = @[
                        @"About",
                        @"Activity Feeds",
                        @"Browser",
                        @"Calculators",
                        @"Calendars",
                        @"Capture",
                        @"Check-in",
                        @"Check-out",
                        @"Coach Marks",
                        @"Comments",
                        @"Content Screen",
                        @"Coverpage",
                        @"Create & Edit",
                        @"Customization",
                        @"Discovery",
                        @"Empty States",
                        @"Find Friends",
                        @"Friends",
                        @"Home",
                        @"App Store",
                        @"Launch Screen",
                        @"Lists",
                        @"Logins",
                        @"Maps",
                        @"Messaging",
                        @"Navigations",
                        @"Notifications",
                        @"Photos",
                        @"Playback",
                        @"Popovers",
                        @"Profiles",
                        @"Purchase",
                        @"Recipe",
                        @"Search",
                        @"Settings",
                        @"Share",
                        @"Shopping Cart",
                        @"Sidebars",
                        @"Signups",
                        @"Storefront",
                        @"Timeline",
                        @"Walkthroughs",
                        @"Widgets",
                    ];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *element = self.datasource[indexPath.row];
    cell.textLabel.text = element;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (cell.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSLog(@"cell.selected: %d", cell.selected);
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selected = !cell.selected;
    
    if (cell.selected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

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
