//
//  ESHarmfulAlgalBloomReportsTableViewController.h
//  EcoSleuth
//
//  Created by Justin Leishman on 8/24/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESHarmfulAlgalBloomReportsTableViewControllerDelegate;

@interface ESHarmfulAlgalBloomReportsTableViewController : UITableViewController

@property (weak) id <ESHarmfulAlgalBloomReportsTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSFetchRequest *fetchRequest;

@property (strong) NSDateFormatter *dateFormatter;

@end

@protocol ESHarmfulAlgalBloomReportsTableViewControllerDelegate <NSObject>

- (void)harmfulAlgalBloomReportsTableViewController:(ESHarmfulAlgalBloomReportsTableViewController *)viewController
                                    didSelectReport:(ESHarmfulAlgalBloomReport *)report;

@end
