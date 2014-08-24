//
//  ESHarmfulAlgalBloomReportsTableViewController.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/24/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESHarmfulAlgalBloomReportsTableViewController.h"

static NSString * const ESHarmfulAlgalBloomReportTableViewCellReuseIdentifier = @"Harmful Algal Bloom Report Table View Cell";

@interface ESHarmfulAlgalBloomReportsTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ESHarmfulAlgalBloomReportsTableViewController

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    [self willChangeValueForKey:@"managedObjectContext"];
    
    _managedObjectContext = managedObjectContext;
    
    [self didChangeValueForKey:@"managedObjectContext"];
    
    [self _updateFetchedResultsController];
}

- (void)setFetchRequest:(NSFetchRequest *)fetchRequest {
    [self willChangeValueForKey:@"fetchRequest"];
    
    _fetchRequest = fetchRequest;
    
    [self didChangeValueForKey:@"fetchRequest"];
    
    [self _updateFetchedResultsController];
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    [self willChangeValueForKey:@"fetchedResultsController"];
    
    _fetchedResultsController = fetchedResultsController;
    
    [self didChangeValueForKey:@"fetchedResultsController"];
    
    [fetchedResultsController.managedObjectContext performBlock:^{
        NSError *error = nil;
        
        if ([fetchedResultsController performFetch:&error] == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }
    }];
}

- (void)_updateFetchedResultsController {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = self.fetchRequest;
    
    if (context != nil && fetchRequest != nil) {
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}

- (void)_configureTableViewCell:(UITableViewCell *)tableViewCell
              forRowAtIndexPath:(NSIndexPath *)indexPath {
    tableViewCell.textLabel.text = nil;
    tableViewCell.detailTextLabel.text = nil;
    tableViewCell.imageView.image = nil;
    tableViewCell.accessoryType = UITableViewCellAccessoryNone;
    
    ESHarmfulAlgalBloomReport *report = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [report.managedObjectContext performBlock:^{
        NSString *formattedDate = [self.dateFormatter stringFromDate:report.timestamp];
        UIImage *image = report.image;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            currentCell.textLabel.text = formattedDate;
            currentCell.imageView.image = image;
            currentCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }];
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ESHarmfulAlgalBloomReportTableViewCellReuseIdentifier
                                                            forIndexPath:indexPath];
    
    [self _configureTableViewCell:cell
                forRowAtIndexPath:indexPath];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
