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

@interface ESSocrataAdapterTests : XCTestCase

@property (readonly) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) ESSocrataAdapter *socrataAdapter;

@end

@implementation ESSocrataAdapterTests

- (void)setUp {
    [super setUp];
    
    self.socrataAdapter = [ESSocrataAdapter new];
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
    
    [self.socrataAdapter submitReport:report completionBlock:^(NSError *error) {
        XCTAssertNil(error,
                     @"Error submitting report: %@",
                     error.localizedDescription);
        
        [expectCompletionBlockToBeCalled fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:120.0
                                 handler:NULL];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [self testSubmittingReport];
    }];
}

@end
