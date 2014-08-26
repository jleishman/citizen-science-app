//
//  ESNavigationViewController.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESNavigationViewController.h"
#import "ESDataAdapter.h"

typedef NS_ENUM(NSInteger, ESDeleteDraftActionSheetButtons) {
    ESDeleteDraftActionSheetButtonDelete = 0,
    ESDeleteDraftActionSheetButtonSave,
    ESDeleteDraftActionSheetButtonCancel
};

typedef void (^ESActionSheetHandler)(NSInteger buttonIndex);

static NSString * const ESNewReportSegueIdentifier = @"New Report";

static NSString * const ESPastReportsSegueIdentifier = @"Past Reports";

static NSString * const ESDraftReportsSegueIdentifier = @"Draft Reports";

@interface ESNavigationViewController ()

@property (strong) ESActionSheetHandler deleteDraftReportHandler;

@end

@interface ESNavigationViewController (ESHarmfulAlgalBloomReportViewControllerDelegate) <ESHarmfulAlgalBloomViewControllerDelegate>

@end

@interface ESNavigationViewController (UIActionSheetDelegate) <UIActionSheetDelegate>

@end

@interface ESNavigationViewController (ESHarmfulAlgalBloomReportsTableViewControllerDelegate) <ESHarmfulAlgalBloomReportsTableViewControllerDelegate>

@end

@implementation ESNavigationViewController

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    return dateFormatter;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ESNewReportSegueIdentifier] == YES) {
        ESHarmfulAlgalBloomReport *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"HarmfulAlgalBloomReport"
                                                                             inManagedObjectContext:self.managedObjectContext];
        
        
        ESHarmfulAlgalBloomViewController *habVC = segue.destinationViewController;
        
        habVC.report = newReport;
        habVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:ESDraftReportsSegueIdentifier] == YES) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Draft Reports Title",
                                                            NSStringFromClass([self class]),
                                                            [NSBundle mainBundle],
                                                            @"Draft Reports",
                                                            nil);
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HarmfulAlgalBloomReport"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"submitted == NO"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                       ascending:NO]];
        
        ESHarmfulAlgalBloomReportsTableViewController *tableVC = segue.destinationViewController;
        
        tableVC.dateFormatter = [ESNavigationViewController dateFormatter];
        tableVC.managedObjectContext = self.managedObjectContext;
        tableVC.fetchRequest = fetchRequest;
        tableVC.navigationItem.title = title;
        tableVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:ESPastReportsSegueIdentifier] == YES) {
        NSString *title = NSLocalizedStringWithDefaultValue(@"Past Reports Title",
                                                            NSStringFromClass([self class]),
                                                            [NSBundle mainBundle],
                                                            @"Past Reports",
                                                            nil);
        
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"HarmfulAlgalBloomReport"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"submitted == YES"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp"
                                                                       ascending:NO]];
        
        ESHarmfulAlgalBloomReportsTableViewController *tableVC = segue.destinationViewController;
        
        tableVC.dateFormatter = [ESNavigationViewController dateFormatter];
        tableVC.managedObjectContext = self.managedObjectContext;
        tableVC.fetchRequest = fetchRequest;
        tableVC.navigationItem.title = title;
        tableVC.delegate = self;
    }
}

@end

@implementation ESNavigationViewController (ESHarmfulAlgalBloomReportViewControllerDelegate)

- (void)harmfulAlgalBloomViewController:(ESHarmfulAlgalBloomViewController *)harmfulAlgalBloomViewController
                        didSubmitReport:(ESHarmfulAlgalBloomReport *)report {
    [harmfulAlgalBloomViewController.navigationController popViewControllerAnimated:YES];
    
    [self.dataAdapter submitReport:report
                   completionBlock:^(NSURLResponse *response,
                                      NSData *data,
                                      NSError *error) {
                        if (error != nil) {
                            // TODO: Show alert view.
                        }
                        else {
                            report.submitted = @(YES);
                            
                            [report.managedObjectContext performBlock:^{
                                [report.managedObjectContext save:NULL];
                            }];
                        }
                    }];
}

- (void)harmfulAlgalBloomViewController:(ESHarmfulAlgalBloomViewController *)harmfulAlgalBloomViewController
                 didCancelEditingReport:(ESHarmfulAlgalBloomReport *)report {
    NSString *cancelButtonTitle = NSLocalizedStringWithDefaultValue(@"Cancel Button Title",
                                                                    NSStringFromClass([self class]),
                                                                    [NSBundle mainBundle],
                                                                    @"Cancel",
                                                                    nil);
    
    NSString *destructiveButtonTitle = NSLocalizedStringWithDefaultValue(@"Destructive Button Title",
                                                                         NSStringFromClass([self class]),
                                                                         [NSBundle mainBundle],
                                                                         @"Delete Draft Report",
                                                                         nil);
    
    NSString *saveAsDraftButtonTitle = NSLocalizedStringWithDefaultValue(@"Save As Draft Button Title",
                                                                         NSStringFromClass([self class]),
                                                                         [NSBundle mainBundle],
                                                                         @"Save Draft Report",
                                                                         nil);
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:saveAsDraftButtonTitle, nil];

    [actionSheet showInView:harmfulAlgalBloomViewController.view];
    
    __weak ESNavigationViewController *weakSelf = self;
    
    self.deleteDraftReportHandler = ^(NSInteger buttonIndex) {
        switch (buttonIndex) {
            case ESDeleteDraftActionSheetButtonDelete:
                [report.managedObjectContext deleteObject:report];
                
                [report.managedObjectContext save:NULL];
                
                [harmfulAlgalBloomViewController.navigationController popViewControllerAnimated:YES];
                break;
            case ESDeleteDraftActionSheetButtonSave:
                [report.managedObjectContext save:NULL];
                
                [harmfulAlgalBloomViewController.navigationController popViewControllerAnimated:YES];
                break;
            case ESDeleteDraftActionSheetButtonCancel:
            default:
                break;
        }
        
        weakSelf.deleteDraftReportHandler = NULL;
    };
}

@end

@implementation ESNavigationViewController (UIActionSheetDelegate)

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (self.deleteDraftReportHandler != NULL) {
        self.deleteDraftReportHandler(buttonIndex);
    }
}

@end

@implementation ESNavigationViewController (ESHarmfulAlgalBloomReportsTableViewControllerDelegate)

- (void)harmfulAlgalBloomReportsTableViewController:(ESHarmfulAlgalBloomReportsTableViewController *)viewController
                                    didSelectReport:(ESHarmfulAlgalBloomReport *)report {
    ESHarmfulAlgalBloomViewController *reportVC = [ESHarmfulAlgalBloomViewController new];
    reportVC.report = report;
    
    [viewController.navigationController pushViewController:reportVC
                                                   animated:YES];
}

@end