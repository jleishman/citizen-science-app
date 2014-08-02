//
//  HABNavigationViewController.m
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/2/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import "HABNavigationViewController.h"

@interface HABNavigationViewController ()

@property (strong, nonatomic) NSManagedObjectContext *editingContext;

@end

@implementation HABNavigationViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"NewReport"] == YES) {
        self.editingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.editingContext.parentContext = self.managedObjectContext;
        
        CSHarmfulAlgalBloomReport *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"HarmfulAlgalBloomReport"
                                                                             inManagedObjectContext:self.editingContext];
        
        
        HABHarmfulAlgalBloomViewController *habVC = segue.destinationViewController;
        
        habVC.report = newReport;
    }
}

@end
