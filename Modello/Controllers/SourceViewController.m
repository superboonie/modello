//
//  SourceViewController.m
//  Modello
//
//  Created by Ziad on 10/12/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "SourceViewController.h"

#import "PlaceholderView.h"
#import "CreateScreenShotViewController.h"

@interface SourceViewController ()
@end

@implementation SourceViewController

#pragma mark - Life Cycle 

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Retieve the options */
    if (self.sourceName) {
        // Add the save bar button to save the screenshots
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(save:)];
        [self.navigationItem setRightBarButtonItem:save];
    } else {
        [self.navigationItem setLeftBarButtonItem:nil];
    }
}

- (void)objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    /* results Found */
    if ([self.objects count] > 0) {
        [PlaceholderView hidePlaceholder];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        /* no results found */
    } else {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [PlaceholderView showPlaceholderWithFrame:self.view.frame inView:self.view];
    }
}

#pragma mark - Accessors

- (NSMutableArray *)selectedObjects
{
    if (_selectedObjects) {
        return _selectedObjects;
    }
    
    _selectedObjects = [NSMutableArray new];
    return _selectedObjects;
}

#pragma mark - Actions 

- (IBAction)add:(id)sender
{
    [UIAlertView showWithTitle:@"What's the name of the app?"
                       message:nil
                         style:UIAlertViewStylePlainTextInput
             cancelButtonTitle:@"Cancel"
             otherButtonTitles:@[@"Done"]
             completionHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
             
                 if (buttonIndex == 1) {
                     
                     // HUD while sending data
                     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                     
                     // Create the project and hold the object to maintain a relation between the screenshots and the parent
                     NSString *name = [alertView textFieldAtIndex:0].text;
                     name = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                     if (![name isEqualToString:@""]) {
                         
                         [Manager createProjectWithName:name
                                      completionHandler:^(PFObject *object, NSError *error) {
                                          
                                          /* Hide HUD when data is loaded */
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          
                                          /* Push to the screenshot screen if the project has been created successfully */
                                          if (!error) {
                                              [self performSegueWithIdentifier:@"ScreenShots" sender:object];
                                              
                                          /* Show the error */
                                          } else {
                                              [UIAlertView showWithTitle:nil
                                                                 message:[error localizedDescription]
                                                       cancelButtonTitle:@"OK"
                                                       completionHandler:NULL];
                                          }
                                      }];
                     }
                 }
             }];
}

- (void)save:(id)sender
{
    NSDictionary *info = @{self.sourceName: self.selectedObjects};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Save ScreenShot Info"
                                                        object:self
                                                      userInfo:info];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (PFQuery *)queryForTable
{
    self.parseClassName = (self.sourceName)? self.sourceName: @"Project";
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByAscending:@"name"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object
{
    static NSString *cellIdentifier = @"Cell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell withObject:object];
    
    return cell;
}

- (void)configureCell:(PFTableViewCell *)cell withObject:(PFObject *)object
{
    [cell.textLabel setText:object[@"name"]];
    
    if (self.sourceName) {
        /* Check or uncheck the previous chosen data */
        if ([Manager objects:self.selectedObjects contain:object]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sourceName) {
        // Retrieve the object
        PFObject *object = [self.objects objectAtIndex:indexPath.row];
        
        /* Mark the chosen info */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            // Hold the object selected
            [self.selectedObjects addObject:object];
          
            /* Unmark unwanted info */
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            // Take off the object unselected
            if ([Manager objects:self.selectedObjects contain:object]) {
                [self.selectedObjects removeObject:object];
            }
        }
    } else {
        [self performSegueWithIdentifier:@"ScreenShots" sender:[self objectAtIndexPath:indexPath]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PFObject *)sender
{
    if ([[segue identifier] isEqualToString:@"ScreenShots"]) {
        [[segue destinationViewController] setProject:sender];
    }
}

@end
