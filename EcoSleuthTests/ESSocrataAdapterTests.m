//
//  ESSocrataAdapterTests.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/13/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ESAppDelegate.h"
#import "ESSocrataAdapter.h"

NSString * const ESSocrataFormURLString = @"https://opendata.socrata.com/views/jraf-t6d8/rows.html?method=createForm&successRedirect=https%3A%2F%2Fopendata.socrata.com%2Fdataset%2FSubmitReport%2Fjraf-t6d8%2Fform_success&errorRedirect=https%3A%2F%2Fopendata.socrata.com%2Fdataset%2FSubmitReport%2Fjraf-t6d8%2Fform_error";

@interface ESSocrataAdapterTests : XCTestCase

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) ESSocrataAdapter *socrataAdapter;

@end

@implementation ESSocrataAdapterTests

- (void)setUp {
    [super setUp];
    
    NSURL *url = [NSURL URLWithString:ESSocrataFormURLString];
    
    XCTAssertNotNil(url, @"URL should not be nil.");
    
    self.socrataAdapter = [[ESSocrataAdapter alloc] initWithURL:url];
}

- (void)tearDown {
    self.socrataAdapter = nil;
    
    [super tearDown];
}

- (NSManagedObjectContext *)managedObjectContext {
    ESAppDelegate *appDelegate = (ESAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    return appDelegate.managedObjectContext;
}

- (void)testSubmittingReport {
    ESHarmfulAlgalBloomReport *report = [NSEntityDescription insertNewObjectForEntityForName:@"HarmfulAlgalBloomReport"
                                                                      inManagedObjectContext:self.managedObjectContext];
    
    XCTestExpectation *expectCompletionBlockToBeCalled = [self expectationWithDescription:@"Completion block should be called."];
    
    [self.socrataAdapter submitReport:report
                      completionBlock:^(NSURLResponse *response,
                                        NSData *data,
                                        NSError *error) {
                          XCTAssertNil(error,
                                       @"Error submitting report: %@",
                                       error.localizedDescription);
                          
                          [expectCompletionBlockToBeCalled fulfill];
                      }];
    
    [self waitForExpectationsWithTimeout:240.0
                                 handler:NULL];
}

- (void)testSubmittingReportPerformance {
    [self measureBlock:^{
        [self testSubmittingReport];
    }];
}

@end
