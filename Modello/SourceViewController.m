//
//  SourceViewController.m
//  Modello
//
//  Created by Ziad on 10/12/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "SourceViewController.h"

#import "Manager.h"
#import "CreateScreenShotViewController.h"

@interface SourceViewController () {
    NSArray *entries_;
}
@property (nonatomic, strong) UILabel *noDataLabel;
@end

@implementation SourceViewController

#pragma mark - Life Cycle 

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // HUD while data is loading
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /* Retieve the options */
    if (self.sourceName) {
        
        // Add the save bar button to save the screenshots
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(save:)];
        [self.navigationItem setRightBarButtonItem:save];
        
        // Load the source from server using the source name
        [Manager findObjectsOfSource:self.sourceName
                   completionHandler:^(NSArray *objects, NSError *error) {
                       [self reloadDataWithObjects:objects error:error];
                   }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /* Retrieve the names of the project names from the server */
    if (!self.sourceName) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self refresh:nil];
        
        /* Refresh projects names when the user create a new one */
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh:)
                                                     name:@"Load Projects Names"
                                                   object:nil];
    }
}

#pragma mark - Refresh

- (void)refresh:(NSNotification *)notifications
{
    /* Load projects names */
    [Manager findObjectsOfSource:@"Project"
               completionHandler:^(NSArray *objects, NSError *error) {
                   [self reloadDataWithObjects:objects error:error];
               }];
}

- (void)reloadDataWithObjects:(NSArray *)objects error:(NSError *)error
{
    /* Hide HUD when data is loaded */
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    /* Show data when there is no error */
    if (!error) {
        /* Data found */
        if ([objects count] > 0) {
            entries_ = objects;
            [self.noDataLabel removeFromSuperview];
            [self.tableView reloadData];
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
          /* Data not found */
        } else {
            CGRect frame = self.view.frame;
            self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 30.f)];
            [self.noDataLabel setCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame) - 30.f)];
            [self.noDataLabel setTextAlignment:NSTextAlignmentCenter];
            [self.noDataLabel setText:@"No project found"];
            [self.tableView addSubview:self.noDataLabel];
        }
        
        
    } else {
        [UIAlertView showWithTitle:@"Error"
                           message:[error localizedDescription]
                 cancelButtonTitle:@"OK"
                 completionHandler:NULL];
    }
}

- (PFObject *)selectedEntriesdoesContain:(PFObject *)entry
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", entry[@"name"]];
    return [[self.entriesSelected filteredArrayUsingPredicate:predicate] lastObject];
}

#pragma mark - Accessors

- (NSMutableArray *)entriesSelected
{
    if (_entriesSelected) {
        return _entriesSelected;
    }
    
    _entriesSelected = [NSMutableArray new];
    return _entriesSelected;
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
                     NSString *name = [[alertView textFieldAtIndex:0].text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
                     if (![name isEqualToString:@""]) {
                         
                         [Manager createProjectWithName:name
                                      completionHandler:^(PFObject *object, NSError *error) {
                                          
                                          /* Hide HUD when data is loaded */
                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                          
                                          /* Push to the screenshot screen if the project has been created successfully */
                                          if (!error) {
                                              id csViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScreenShots"];
                                              [csViewController setProject:object];
                                              [self.navigationController pushViewController:csViewController animated:YES];
                                              
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
    NSDictionary *info = @{self.sourceName: self.entriesSelected};
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [entries_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PFObject *entry = [entries_ objectAtIndex:indexPath.row];
    [cell.textLabel setText:entry[@"name"]];
    
    if (self.sourceName) {
        /* Check or uncheck the previous chosen data */
        if ([self selectedEntriesdoesContain:entry]) {
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
        PFObject *entry = [entries_ objectAtIndex:indexPath.row];
        
        /* Mark the chosen info */
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryNone) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
            // Hold the object selected
            [self.entriesSelected addObject:entry];
          
            /* Unmark unwanted info */
        } else {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            // Take off the object unselected
            PFObject *entryFound = [self selectedEntriesdoesContain:entry];
            if (entryFound) {
                [self.entriesSelected removeObject:entryFound];
            }
        }
    } else {
        id csViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScreenShots"];
        [csViewController setProject:[entries_ objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:csViewController animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
