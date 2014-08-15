//
//  ESWebServiceAdapter.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/12/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESWebServiceAdapter.h"

static NSString * const ESWebServiceDataName = @"Web Service";

static NSString * const ESWebServiceURLKey = @"URL";

@interface ESWebServiceAdapter ()

@property (strong, nonatomic) NSOperationQueue *urlConnectionOperationQueue;

@end

@implementation ESWebServiceAdapter

- (void)submitReport:(ESHarmfulAlgalBloomReport *)report
     completionBlock:(ESDataAdapterCompletionBlock)completionBlock {
    NSDictionary *dictionary = @{@"water_color" : report.waterColor,
                                 @"algae_color" : report.algaeColor,
                                 @"color_in_water_column" : report.colorInWaterColumn,
                                 @"lat" : report.latitude,
                                 @"long" : report.longitude};
    
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:0
                                                     error:&error];
    
    NSURL *webServiceDataURL = [[NSBundle mainBundle] URLForResource:ESWebServiceDataName
                                                       withExtension:@"plist"];
    
    NSDictionary *webServiceData = [NSDictionary dictionaryWithContentsOfURL:webServiceDataURL];
    
    NSURL *webServiceURL = [NSURL URLWithString:webServiceData[ESWebServiceURLKey]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:webServiceURL];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = data;
    
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    void (^handler)(NSURLResponse *,
                    NSData *,
                    NSError *) = ^(NSURLResponse *urlResponse,
                                   NSData *data,
                                   NSError *connectionError) {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]] == YES) {
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)urlResponse;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                NSError *error = nil;
                
                if (httpURLResponse.statusCode != 200) {
                    error = nil;
                }
                else {
                }
                
                if (completionBlock != NULL) {
                    completionBlock(error);
                }
            }];
        }
    };
    
    self.urlConnectionOperationQueue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:self.urlConnectionOperationQueue
                           completionHandler:handler];
}

@end
