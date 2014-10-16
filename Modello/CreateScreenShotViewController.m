//
//  CreateScreenShotViewController.m
//  Modello
//
//  Created by Ziad on 10/13/14.
//  Copyright (c) 2014 TAMIN Lab. All rights reserved.
//

#import "CreateScreenShotViewController.h"

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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[self.project relationForKey:@"platform"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [projectInfo_ setValue:objects forKey:@"Platform"];
            
            [[[self.project relationForKey:@"category"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [projectInfo_ setValue:objects forKey:@"Category"];
                
                PFQuery *query = [PFQuery queryWithClassName:@"ScreenShot"];
                [query whereKey:@"parent" equalTo:self.project];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    [objects enumerateObjectsUsingBlock:^(PFObject *screenshot, NSUInteger idx, BOOL *stop) {
                        
                        PFFile *file = screenshot[@"imagefile"];
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                            NSMutableDictionary *parsedScreenshot = [@{@"imageFile": data} mutableCopy];
                            
                            [[[screenshot relationForKey:@"userexperience"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                [parsedScreenshot setObject:objects forKey:@"UserExperience"];
                                
                                [[[screenshot relationForKey:@"userinterface"] query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                    [parsedScreenshot setObject:objects forKey:@"UserInterface"];
                                    
                                    [screenshotInfo_ addObject:parsedScreenshot];
                                    
                                    
                                    /* Hide HUD when data is loaded */
                                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                                    // Update labels
                                    [self updatePlaceholders];
                                    [self refreshGallery];
                                }];
                            }];
                        }];
                        
                    }];
                    
                    
                }];
                
            }];
        }];
        
    }
}

#pragma mark - 

- (void)resetAll
{
    [projectInfo_ removeAllObjects]; [screenshotInfo_ removeAllObjects];
    [self.labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL *stop) {
        [label setText:placeholders_[idx]];
        [label setTextColor:[UIColor lightGrayColor]];
    }];
    
    [self.scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}

- (void)updatePlaceholders
{
    [projectInfo_ enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        
        /* Collect the infos chosen */
        NSMutableArray *names = [NSMutableArray new];
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [names addObject:obj[@"name"]];
        }];
        
        /* Update the placeholder witth the infos chosen */
        NSUInteger index = [classesNames_ indexOfObject:key];
        UILabel *label = self.labels[index + 1];
        /* Change the color of the label and put the chosen infos */
        if ([names count] > 0) {
            [label setTextColor:[UIColor blackColor]];
            [label setText:[names componentsJoinedByString:@", "]];
            
            /* If there is no info chosen, show the placeholder */
        } else {
            [label setTextColor:[UIColor lightGrayColor]];
            [label setText:placeholders_[index + 1]];
        }
    }];
    
    if (![screenshotInfo_ count]) {
        return;
    }
    
    NSDictionary *currentInfo = screenshotInfo_[currentIndex_];
    [currentInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {

        if (![key isEqualToString:@"imageFile"]) {

            /* Collect the infos chosen */
            NSMutableArray *names = [NSMutableArray new];
            [obj enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [names addObject:obj[@"name"]];
            }];

            /* Update the placeholder witth the infos chosen */
            NSUInteger index = [classesNames_ indexOfObject:key];
            UILabel *label = self.labels[index + 1];
            /* Change the color of the label and put the chosen infos */
            if ([names count] > 0) {
                [label setTextColor:[UIColor blackColor]];
                [label setText:[names componentsJoinedByString:@", "]];
                
              /* If there is no info chosen, show the placeholder */
            } else {
                [label setTextColor:[UIColor lightGrayColor]];
                [label setText:placeholders_[index + 1]];
            }
        }
    }];
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
                    [UIAlertView showWithTitle:@"Submit Error"
                                       message:[NSString stringWithFormat:@"Please enter %@ for screenshot #%lu", placeholders_[idx + 1], (unsigned long)index + 1]
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
   
    [self updatePlaceholders];
}

#pragma mark - Gallery

- (void)refreshGallery
{
    __block float width = CGRectGetWidth(self.scrollView.bounds) , height = CGRectGetHeight(self.scrollView.bounds);
    
    [self.scrollView setContentSize:CGSizeMake(width * [screenshotInfo_ count], height)];
    [screenshotInfo_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((width * idx), 0, width, height)];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setImage:[UIImage imageWithData:obj[@"imageFile"]]];
        [self.scrollView addSubview:imageView];
    }];
}

#pragma mark - Scroll delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float width = CGRectGetWidth(self.scrollView.bounds);
    float offset = scrollView.contentOffset.x;
    currentIndex_ = offset/width;
    
    [self updatePlaceholders];
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
        SourceViewController *sourceViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Source"];
        [sourceViewController setSourceName:className];
        if ([projectInfo_ objectForKey:className]) {
            [sourceViewController setEntriesSelected:[projectInfo_ valueForKey:className] ];
        }
        
        else if ([screenshotInfo_ count]){
            NSDictionary *entry = [screenshotInfo_ objectAtIndex:currentIndex_];
            [sourceViewController setEntriesSelected:[[entry valueForKey:className] mutableCopy]];
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
