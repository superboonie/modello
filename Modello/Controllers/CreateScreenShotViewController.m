//
//  CreateScreenShotViewController.m
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "CreateScreenShotViewController.h"

#import "UILabel+Additions.h"
#import "UIActionSheet+Blocks.h"
#import "ELCImagePickerController.h"
#import "SourceViewController.h"

@interface CreateScreenShotViewController ()<ELCImagePickerControllerDelegate,UIScrollViewDelegate> {
    NSMutableDictionary *projectInfo_;
    NSMutableArray *screenshotInfo_;
    NSArray *classesNames_, *placeholders_;
    int currentIndex_;
}
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *labels;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@end

@implementation CreateScreenShotViewController

#pragma mark - Life Cycle 

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Project name
    screenshotInfo_ = [NSMutableArray new];
    projectInfo_ = [NSMutableDictionary new];
    [self setTitle:self.project[@"name"]];
    
    // Sources names
    classesNames_ = @[@"Platform", @"Category", @"UserExperience", @"UserInterface"];
    placeholders_ = @[@"Send a ScreenShot", @"Platforms", @"Categories", @"UX", @"UI"];
    
    // Save ScreenShot Info
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveScreenShotInfo:)
                                                 name:@"Save ScreenShot Info"
                                               object:nil];
    
    // Display Previous
    if ([self.project valueForKey:@"category"]) {
        /* */
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        /* */
        [Manager fetchProjectInfo:self.project
                completionHandler:^(NSDictionary *projectInfo, NSArray *screenshotInfo, NSError *error) {
            
                    /* Hide HUD when data is loaded */
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    // Save data retrieved
                    projectInfo_ = [projectInfo mutableCopy];
                    screenshotInfo_ = [screenshotInfo mutableCopy];
                    
                    // Update labels
                    [self refreshData];
                    [self refreshGallery];
        }];
    }
}

#pragma mark -

- (void)refreshData
{
    [projectInfo_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [UILabel updateLabels:self.labels
                  withObjects:obj
                          key:key
                      classes:classesNames_
                 placeholders:placeholders_];
    }];
    
    
    if ([screenshotInfo_ count]) {
        UILabel *label = (UILabel *)self.labels[0];
        [label setTextColor:[UIColor blackColor]];
        [label setText:@"Screenshots attached"];
    }
    
    if ([screenshotInfo_ count]) {
        NSDictionary *currentInfo = screenshotInfo_[currentIndex_];
        [currentInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if (![key isEqualToString:@"imageFile"]) {
                [UILabel updateLabels:self.labels
                          withObjects:obj
                                  key:key
                              classes:classesNames_
                         placeholders:placeholders_];
            }
        }];
    }
}

- (BOOL)validate
{
    /* Check of an image was chosen */
    if (![screenshotInfo_ count]) {
        [UIAlertView showWithTitle:@"Error"
                           message:@"Please attached a screenshot"
                 cancelButtonTitle:@"OK"
                 completionHandler:NULL];
        
        return NO;
    }
    
    /* Check if the infos were chosen */
    __block BOOL result = YES;
    [classesNames_ enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        // Project Infos validation
        if (idx < 2) {
            if (![[projectInfo_ allKeys] containsObject:key]) {
                result = NO;
                [UIAlertView showWithTitle:@"Error"
                                   message:[NSString stringWithFormat:@"Please enter %@", placeholders_[idx + 1]]
                         cancelButtonTitle:@"OK"
                         completionHandler:NULL];
                *stop = YES;
            }
            /* Screenshots Infos validation */
        } else {
            [screenshotInfo_ enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger index, BOOL *stop) {
                
                if (![[obj valueForKey:key] count]) {
                    result = NO;
                    NSString *message = [NSString stringWithFormat:@"Please enter %@ for screenshot #%lu",
                                         placeholders_[idx + 1],
                                         (unsigned long)index + 1];
                    
                    [UIAlertView showWithTitle:@"Submit Error"
                                       message:message
                             cancelButtonTitle:@"OK"
                             completionHandler:NULL];
                    *stop = YES;
                }
            }];
            
            /* Stop looping */
            if (result == NO) {
                *stop = YES;
            }
        }
    }];
    
    return result;
}

#pragma mark - Notifications

- (void)saveScreenShotInfo:(NSNotification *)notification
{
    /* Check if the info chosen are Categories or Platforms */
    NSString *key = [[[notification userInfo] allKeys] lastObject];
    if ([key isEqualToString:classesNames_[0]] ||
        [key isEqualToString:classesNames_[1]]) {
        [projectInfo_ addEntriesFromDictionary:notification.userInfo];
       
      // We keep the user interface and user experience related to each image
    } else {
        NSMutableDictionary *currentInfo = [screenshotInfo_[currentIndex_] mutableCopy];
        [currentInfo addEntriesFromDictionary:notification.userInfo];
        [screenshotInfo_ replaceObjectAtIndex:currentIndex_ withObject:currentInfo];
    }
   
    [self refreshData];
}

#pragma mark - Gallery

- (void)refreshGallery
{
    // Check if there is any screenshot
    if (![screenshotInfo_ count]) {
        return;
    }
    
    // Clear the old images before showing the new ones
    [self clearGallery];
    
    // Enable user interaction when the user has selected images
    for (int i = 2; i <= 3; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i
                                                                                         inSection:1]];
        [cell setUserInteractionEnabled:YES];
    }
    
    // Show the images selected
    __block float width = CGRectGetWidth(self.scrollView.bounds) , height = CGRectGetHeight(self.scrollView.bounds);
    [self.scrollView setContentSize:CGSizeMake(width * [screenshotInfo_ count], height)];
    [screenshotInfo_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((width * idx), 0, width, height)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        /* Load images from the server */
        if ([obj[@"imageFile"] isKindOfClass:[PFFile class]]) {
            [(PFFile *)obj[@"imageFile"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [imageView setImage:[UIImage imageWithData:data]];
            }];
        /* Load local images */
        } else {
            [imageView setImage:[UIImage imageWithData:obj[@"imageFile"]]];
        }
        [self.scrollView addSubview:imageView];
    }];
}

- (void)clearGallery
{
    // Disable user interaction when there is no image
    for (int i = 2; i <= 3; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath
                                                                       indexPathForRow:i inSection:1]];
        [cell setUserInteractionEnabled:NO];
    }
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Check the selected photo to update data related to it
    float width = CGRectGetWidth(self.scrollView.bounds);
    float offset = scrollView.contentOffset.x;
    currentIndex_ = offset/width;
    [self refreshData];
}

#pragma mark - ELC delegate 

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    // Change the placeholder
    UILabel *label = (UILabel *)self.labels[0];
    [label setTextColor:[UIColor blackColor]];
    [label setText:@"Screenshots attached"];
    
    // Hold the image taken
    [info enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSData *data = UIImageJPEGRepresentation(obj[UIImagePickerControllerOriginalImage], .5f);
        [screenshotInfo_ addObject:@{@"imageFile": data,
                                     @"UserExperience": @[],
                                     @"UserInterface": @[]}];
    }];
    
    // Refresh the gallery
    [self refreshGallery];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions

- (IBAction)save:(id)sender
{
    // Validate data
    if (![self validate]) {
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /* Update the project with the selected Categories and Platforms */
    [Manager updateProject:self.project newInfo:projectInfo_ completionHandler:^(NSError *error) {
        
        /* Create the screenshot */
        [Manager createScreenshots:screenshotInfo_ inProject:self.project completionHandler:^(NSError *error) {
            
            /* Hide HUD when data is loaded */
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            /* Images created successfully */
            if (!error) {
                [self.navigationController popToRootViewControllerAnimated:YES];
                
                /* Show the error occured while uploading the screenshots */
            } else {
                [UIAlertView showWithTitle:@"Error"
                                   message:[error localizedDescription]
                         cancelButtonTitle:@"OK"
                         completionHandler:NULL];
            }
        }];
    }];
}

- (void)resetAll
{
    [projectInfo_ removeAllObjects]; [screenshotInfo_ removeAllObjects];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        [label setText:placeholders_[idx]];
        [label setTextColor:[UIColor lightGrayColor]];
    }];
    
    [self clearGallery];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* Present Picker to let the user choose an image */
    if (indexPath.section == 0 && indexPath.row == 0) {
        ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] init];
        imagePicker.imagePickerDelegate = self;
        [self presentViewController:imagePicker animated:YES completion:NULL];
    
      /* Display the source chosen */
    } else if (indexPath.section == 1) {
        NSString *className = classesNames_[indexPath.row];
        id sourceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Source"];
        [sourceViewController setSourceName:className];
        
        // Pass selected Infos
        if ([projectInfo_ objectForKey:className]) {
            [sourceViewController setSelectedObjects:[projectInfo_ valueForKey:className]];
            
        } else if ([screenshotInfo_ count]){
            NSDictionary *object = screenshotInfo_[currentIndex_];
            [sourceViewController setSelectedObjects:[[object valueForKey:className] mutableCopy]];
        }
        [self.navigationController pushViewController:sourceViewController animated:YES];
        
        /* Reset all */
    } else if (indexPath.section == 2) {
        [UIActionSheet showIn:self.view
                        title:nil
            cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:@"Reset All"
            otherButtonTitles:nil
            completionHandler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                
                if (buttonIndex == 0) {
                    [self resetAll];
                }
                
            }];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
