//
//  ESNavigationViewController.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESNavigationViewController.h"
#import "ESSocrataAdapter.h"

@interface ESNavigationViewController ()

@property (strong, nonatomic) NSManagedObjectContext *editingContext;

@end

@implementation ESNavigationViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewReport"] == YES) {
        self.editingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.editingContext.parentContext = self.managedObjectContext;
        
        ESHarmfulAlgalBloomReport *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"HarmfulAlgalBloomReport"
                                                                             inManagedObjectContext:self.editingContext];
        
        
        ESHarmfulAlgalBloomViewController *habVC = segue.destinationViewController;
        
        habVC.report = newReport;
        habVC.dataReporter = [ESSocrataAdapter new];
    }
}

@end
